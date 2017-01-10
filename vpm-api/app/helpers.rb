require 'faraday'
require 'json'
require 'logger'
require 'openssl'
require 'yaml'

# Helper methods
module Helpers
  # Require the other modules
  require 'r10k'
  include R10K

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
    configure_api
  end

  def configure_api
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

  # Deployment
  def deploy
    deploy_secure_files_thread
    deploy_hieradata_thread
    deploy_r10k_thread
  end

  # Deploy secure files
  def deploy_secure_files_thread
    Thread.new { download_secure_files }
  end

  # Deploy Hiera data
  def deploy_hieradata_thread
    Thread.new { download_hieradata }
  end

  # Deployment
  def deploy_r10k_thread
    Thread.new { deploy_r10k }
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
    credentials = @auth.credentials
    @auth.provided? && @auth.basic? && credentials && credentials == [config['user'], config['pass']]
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
end # module APPHelpers
