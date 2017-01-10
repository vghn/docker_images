require 'base64'
require 'erb'
require 'faraday'
require 'fileutils'
require 'json'
require 'logger'
require 'openssl'
require 'yaml'

# Helper methods
module APPHelpers
  # Logging
  def logger
    @logger ||= Logger.new(STDOUT)
  end

  # Configuration
  def config
    @config ||= YAML.load_file(config_file)
  end

  # Intitial deployment
  def initial_deployment
    logger.info 'Start initial deployment'
    deploy

    if config_file
      logger.info 'Wait for the configuration'
      sleep 1 until File.exist?(config_file)
      logger.info 'Configuration found'
    else
      logger.warn 'Skip configuration because API_CONFIG is not set!'
    end
  end

  # Download secure files
  def download_secure_files
    if secure_s3path
      logger.info 'Download secure files'
      logger.debug `aws s3 sync --delete --exact-timestamps #{secure_s3path}/ /etc/puppetlabs/secure/ && find /etc/puppetlabs/secure/ -type d -empty -delete`
      File.write('/var/local/deployed_secure_files', Time.now.localtime)
      logger.info 'Secure files downloaded'
    else
      logger.warn 'Skip downloading secure files because SECURE_S3PATH is not set!'
    end
  end

  # Download Hiera data
  def download_hieradata
    if hiera_s3path
      logger.info 'Download Hiera data'
      logger.debug `aws s3 sync --delete --exact-timestamps #{hiera_s3path}/ /etc/puppetlabs/hieradata/ && find /etc/puppetlabs/hieradata/ -type d -empty -delete`
      File.write('/var/local/deployed_hieradata', Time.now.localtime)
      logger.info 'Hiera data downloaded'
    else
      logger.warn 'Skip downloading hiera data because HIERA_S3PATH is not set!'
    end
  end

  # R10K configuration template
  def r10k_template
    <<-EOT
cachedir: '/opt/puppetlabs/r10k/cache'
sources:
  operations:
    remote: '<%= control_repo %>'
    basedir: '/etc/puppetlabs/code/environments'
    EOT
  end

  # R10K configuration
  def r10k_config
    r10k_config ||= ERB.new(r10k_template).result(binding)
  end

  # Generate R10K configuration
  def write_r10k_config
    logger.info 'Generate R10K configuration'
    FileUtils.mkdir_p('/etc/puppetlabs/r10k')
    File.write('/etc/puppetlabs/r10k/r10k.yaml', r10k_config)
    logger.info 'R10K configuration created'
  end

  # Deploy R10K
  def deploy_r10k
    if control_repo
      if File.exist?('/etc/puppetlabs/r10k/r10k.yaml') && \
         File.read('/etc/puppetlabs/r10k/r10k.yaml') == r10k_config
        logger.info 'R10K configuration has not changed'
      else
        write_r10k_config
      end
      logger.info 'Deploy R10K'
      logger.debug `r10k deploy environment --puppetfile`
      File.write('/var/local/deployed_r10k', Time.now.localtime)
      logger.info 'R10K deployed'
    else
      logger.warn 'Skip R10K deployment because CONTROL_REPO is not set!'
    end
  end

  # Deployment
  def deploy
    Thread.new { download_secure_files }
    Thread.new { download_hieradata }
    Thread.new { deploy_r10k }
  end

  # Only allow authorized requests
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      return halt 401, 'Not authorized'
    end
  end

  # Check credentials
  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials &&
      @auth.credentials == [config['user'], config['pass']]
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
    conn = Faraday.new(url: 'https://api.travis-ci.org') do |faraday|
      faraday.adapter Faraday.default_adapter
    end
    response = conn.get '/config'
    JSON.parse(response.body)['config']['notifications']['webhook']['public_key']
  end
end # module APPHelpers
