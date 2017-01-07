require 'base64'
require 'erb'
require 'faraday'
require 'json'
require 'json'
require 'logger'
require 'logger'
require 'openssl'
require 'sinatra'
require 'sinatra/base'
require 'yaml'

# Logging
def log
  Logger.new(STDOUT)
end

# Configuration
def config
  if File.exist?(ENV['API_CONFIG'])
    YAML.load_file(ENV['API_CONFIG'])
  else
    raise "Configuration file '#{ENV['API_CONFIG']}' does not exist"
  end
end

# Download secure files
def download_secure_files
  if ENV['SECURE_S3PATH']
    log.info 'Download secure files'
    puts `aws s3 sync --delete --exact-timestamps #{ENV['SECURE_S3PATH']}/ /etc/puppetlabs/secure/ && find /etc/puppetlabs/secure/ -type d -empty -delete`
    File.write('/var/local/deployed_secure_files', Time.now.localtime)
    log.info 'Secure files downloaded'
  else
    log.warn 'Skip downloading secure files because SECURE_S3PATH is not set!'
  end
end

# Download Hiera data
def download_hieradata
  if ENV['HIERA_S3PATH']
    log.info 'Download Hiera data'
    puts `aws s3 sync --delete --exact-timestamps #{ENV['HIERA_S3PATH']}/ /etc/puppetlabs/hieradata/ && find /etc/puppetlabs/hieradata/ -type d -empty -delete`
    File.write('/var/local/deployed_hieradata', Time.now.localtime)
    log.info 'Hiera data downloaded'
  else
    log.warn 'Skip downloading hiera data because HIERA_S3PATH is not set!'
  end
end

# R10K configuration template
def r10k_template
  <<~EOT
    ---
    cachedir: '/opt/puppetlabs/r10k/cache'
    sources:
      operations:
        remote: '<%= ENV['CONTROL_REPO'] %>'
        basedir: '/etc/puppetlabs/code/environments'
  EOT
end

# R10K configuration
def r10k_config
  r10k_config ||= ERB.new(r10k_template).result(binding)
end

# Generate R10K configuration
def write_r10k_config
  log.info 'Generate R10K configuration'
  File.write('r10k.yaml', r10k_config)
  log.info 'R10K configuration created'
end

# Deploy R10K
def deploy_r10k
  if ENV['CONTROL_REPO']
    if File.exist?('r10k.yaml') && File.read('r10k.yaml') == r10k_config
      log.info 'R10K configuration has not changed'
    else
      write_r10k_config
    end
    log.info 'Deploy R10K'
    `r10k deploy environment --puppetfile`
    File.write('/var/local/deployed_r10k', Time.now.localtime)
    log.info 'R10K deployed'
  else
    log.warn 'Skip R10K deployment because CONTROL_REPO is not set!'
  end
end

# Deployment
def deploy
  log.info 'Deployment will start in the background'
  Thread.new { download_secure_files }
  Thread.new { download_hieradata }
  Thread.new { deploy_r10k }
end

def protected!
  unless authorized?
    response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
    return halt 401, 'Not authorized'
  end
end

def authorized?
  @auth ||= Rack::Auth::Basic::Request.new(request.env)
  @auth.provided? && @auth.basic? && @auth.credentials &&
    @auth.credentials == [config['user'], config['pass']]
end

def verify_github_signature(payload_body)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), config['github_secret'], payload_body)
  return halt 500, 'Signatures did not match!' unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end

def verify_travis_signature(payload)
  signature = request.env['HTTP_SIGNATURE']
  pkey      = OpenSSL::PKey::RSA.new(travis_public_key)

  return halt 500, 'Signatures did not match!' unless pkey.verify(OpenSSL::Digest::SHA1.new, Base64.decode64(signature), payload.to_json)
end

def travis_public_key
  conn = Faraday.new(url: 'https://api.travis-ci.org') do |faraday|
    faraday.adapter Faraday.default_adapter
  end
  response = conn.get '/config'
  JSON.parse(response.body)['config']['notifications']['webhook']['public_key']
end

# Sinatra Application Class
class API < Sinatra::Base
  # Logging
  configure :production, :development do
    enable :logging
  end

  configure :test do
    set :logging, ::Logger::ERROR
  end

  configure :development do
    set :logging, ::Logger::DEBUG
  end

  configure :production do
    set :logging, ::Logger::INFO
  end

  # Intitial deployment
  unless ENV['RACK_ENV'] == 'test'
    log.info 'Initial deployment'
    deploy
  end

  get '/' do
    'Nothing here! Yet!'
  end

  post '/travis' do
    payload = JSON.parse(params[:payload])
    verify_travis_signature(payload)

    deploy
    log.info "Deployment requested from build ##{payload['number']} for the #{payload['branch']} " \
             "branch of repository #{payload['repository']['name']}"

    'Deployment started'
  end

  post '/github' do
    request.body.rewind
    verify_github_signature(request.body.read)
    payload = JSON.parse(params[:payload])

    deploy
    log.info "Requested by GitHub user @#{payload['sender']['login']}"

    'Deployment started'
  end

  post '/slack' do
    token   = params.fetch('token').strip
    user    = params.fetch('user_name').strip
    channel = params.fetch('channel_name').strip
    command = params.fetch('command').strip
    text    = params.fetch('text').strip

    if token == config['slack_token']
      log.info "Authorized request from slacker @#{user} on channel ##{channel}"
    else
      log.warn "Unauthorized token received from slacker @#{user}"
    end

    case command
    when '/rhea'
      case text
      when 'deploy'
        # Only use the threaded deployment because of the short timeout
        deploy
        'Deployment started :thumbsup:'
      else
        "I don't understand '#{text}' :cry:"
      end
    else
      "Unknown command '#{command}' :cry:"
    end
  end

  # Show environment info
  get '/env' do
    protected!
    if params[:json] == 'yes'
      content_type :json
      ENV.to_h.to_json
    else
      'Environment (as <a href="/env?json=yes">JSON</a>):<ul>' +
        ENV.each.map { |k, v| "<li><b>#{k}:</b> #{v}</li>" }.join + '</ul>'
    end
  end

  get '/status' do
    'Alive'
  end
end # class API
