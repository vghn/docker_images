require 'base64'
require 'erb'
require 'faraday'
require 'fileutils'
require 'json'
require 'logger'
require 'openssl'
require 'rack'
require 'sinatra'
require 'yaml'

# VARs
CONFIG_FILE   = ENV['API_CONFIG']
DATA_SERVICE  = ENV['DATA_SERVICE']
SECURE_S3PATH = ENV['SECURE_S3PATH']
HIERA_S3PATH  = ENV['HIERA_S3PATH']
CONTROL_REPO  = ENV['CONTROL_REPO']

# Logging
def logger
  @logger ||= Logger.new(STDOUT)
end

# Configuration
def config
  @config ||= YAML.load_file(CONFIG_FILE)
end

# Wait for the configuration
def wait_for_config
  if CONFIG_FILE
    logger.info 'Wait for the configuration'
    sleep 1 until File.exist?(CONFIG_FILE)
    logger.info 'Configuration found'
  else
    logger.warn 'Skip configuration because API_CONFIG is not set!'
  end
end

# Get the data container ID
def data_container_id
  data_service_name = ENV['DATA_SERVICE'] || 'data'

  @data_container_id ||= `docker ps --latest --all --filter \
    "label=com.docker.compose.service=#{data_service_name}" \
    --format "{{.ID}}"`.chomp
end

# Compose the volume arguments for the Docker command
def docker_cmd
  @docker_cmd = 'docker run --rm'
  if data_container_id != ''
    @docker_cmd += " --volumes-from #{data_container_id}"
  end
  return @docker_cmd
end

# Initial deployment
def initial_deployment
  logger.info 'Start initial deployment'
  deploy
  wait_for_config
end

# Deployment
def deploy
  deploy_secure_files_thread
  deploy_hieradata_thread
  deploy_r10k_thread
end

# Deploy secure files
def deploy_secure_files_thread
  if SECURE_S3PATH
    Thread.new { download_secure_files }
  else
    logger.warn 'Skip downloading secure files because SECURE_S3PATH is not set!'
  end
end

# Deploy Hiera data
def deploy_hieradata_thread
  if HIERA_S3PATH
    Thread.new { download_hieradata }
  else
    logger.warn 'Skip downloading hiera data because HIERA_S3PATH is not set!'
  end
end

# Deployment
def deploy_r10k_thread
  if CONTROL_REPO
    Thread.new { deploy_r10k }
  else
    logger.warn 'Skip R10K deployment because CONTROL_REPO is not set!'
  end
end

# Download secure files
# '--volumes-from' is needed here because docker in docker does not work with
# volumes mounted from the host
def download_secure_files
  logger.info 'Download secure files'
  if system "#{docker_cmd} \
    vladgh/awscli sh -c 'aws s3 sync --delete --exact-timestamps \
      #{SECURE_S3PATH}/ /etc/puppetlabs/secure/ && \
      find /etc/puppetlabs/secure/ -type d -empty -delete'"
    File.write('/var/local/deployed_secure_files', Time.now.localtime)
    logger.info 'Secure files downloaded'
  else
    logger.warn 'Failed to download secure files'
  end
end

# Download Hiera data
def download_hieradata
  logger.info 'Download Hiera data'
  if system "#{docker_cmd} \
    vladgh/awscli sh -c 'aws s3 sync --delete --exact-timestamps \
      #{HIERA_S3PATH}/ /etc/puppetlabs/hieradata/ && \
      find /etc/puppetlabs/hieradata/ -type d -empty -delete'"
    File.write('/var/local/deployed_hieradata', Time.now.localtime)
    logger.info 'Hiera data downloaded'
  else
    logger.warn 'Failed to download Hiera data'
  end
end

# Deploy R10K
def deploy_r10k
  logger.info 'Deploy R10K'
  if system "#{docker_cmd} \
    -e REMOTE='#{CONTROL_REPO}' \
    vladgh/r10k r10k deploy environment --puppetfile"
    File.write('/var/local/deployed_r10k', Time.now.localtime)
    logger.info 'R10K deployed'
  else
    logger.warn 'Failed to deploy R10K'
  end
end

# Only allow authorized requests
def protected!
  return if authorized?
  response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
  halt 401, 'Not authorized'
end

# Check credentials
def authorized?
  @auth ||= Rack::Auth::Basic::Request.new(request.env)
  @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [config['user'], config['pass']]
end

# Verify GitHub signature
def verify_github_signature(payload_body)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), config['github_secret'], payload_body)
  return halt 500, 'Signatures did not match!' unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end

# Verify Travis signature
def verify_travis_signature(payload)
  signature = request.env['HTTP_SIGNATURE']
  pkey      = OpenSSL::PKey::RSA.new(travis_public_key)

  return halt 500, 'Signatures did not match!' unless pkey.verify(OpenSSL::Digest::SHA1.new, Base64.decode64(signature), payload.to_json)
end

# Get Travis public key
def travis_public_key
  @conn = Faraday.new(url: 'https://api.travis-ci.org') do |faraday|
    faraday.adapter Faraday.default_adapter
  end
  response = @conn.get '/config'
  JSON.parse(response.body)['config']['notifications']['webhook']['public_key']
end

# Configure Sinatra
enable :logging

# Production settings
configure :production do
  logger.level = Logger::INFO
end

# Flush output immediately
$stdout.sync = true

# Start initial deplyment
initial_deployment unless settings.test?

# Home
get '/' do
  'Nothing here! Yet!'
end

# Travis webhook
post '/travis' do
  payload = JSON.parse(params[:payload])
  verify_travis_signature(payload)

  deploy
  logger.info "Deployment requested from build ##{payload['number']} for the #{payload['branch']} " \
              "branch of repository #{payload['repository']['name']}"

  'Deployment started'
end

# GitHub webhook
post '/github' do
  request.body.rewind
  verify_github_signature(request.body.read)
  payload = JSON.parse(params[:payload])

  deploy
  logger.info "Requested by GitHub user @#{payload['sender']['login']}"

  'Deployment started'
end

# Slack slash command
post '/slack' do
  token   = params.fetch('token').strip
  user    = params.fetch('user_name').strip
  channel = params.fetch('channel_name').strip
  command = params.fetch('command').strip
  text    = params.fetch('text').strip

  if token == config['slack_token']
    logger.info "Authorized request from slacker @#{user} on channel ##{channel}"
  else
    log.warn "Unauthorized token received from slacker @#{user}"
  end

  case command
  when '/rhea'
    case text
    when 'deploy'
      # Only use the threaded deployment because of the short timeout
      deploy
      'Deployment started in the background :thumbsup:'
    else
      "I don't understand '#{text}' :cry:"
    end
  else
    "Unknown command '#{command}' :cry:"
  end
end

# Environment info
get '/env' do
  protected!
  if params[:json] == 'yes'
    content_type :json
    ENV.to_h.to_json
  else
    'Environment (as <a href="/env?json=yes">JSON</a>):<ul>' +
      ENV.each.map { |key, value| "<li><b>#{key}:</b> #{value}</li>" }
      .join + '</ul>'
  end
end

# Status
get '/status' do
  "Alive #{ENV['HOSTNAME']} (#{ENV['RACK_ENV']})"
end
