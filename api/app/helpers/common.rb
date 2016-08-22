require 'logger'
require 'openssl'
require 'yaml'
require 'digest/sha2'

# Logging
def log
  Logger.new(STDOUT)
end

# Configuration
def config
  if File.exist?(ENV['DATA_CONFIG'])
    YAML.load_file(ENV['DATA_CONFIG'])
  else
    raise "Configuration file '#{ENV['DATA_CONFIG']}' does not exist"
  end
end

# Download vault
def download_vault
  if ENV['VAULT_S3PATH']
    log.info 'Download vault'
    puts `aws s3 sync #{ENV['VAULT_S3PATH']} /etc/puppetlabs/vault/ --delete`
    File.write('/var/local/deployed_vault', Time.now.localtime)
  else
    log.warn 'Skip downloading vault because VAULT_S3PATH is not set!'
  end
end

# Download Hiera data
def download_hieradata
  if ENV['HIERA_S3PATH']
    log.info 'Download Hiera data'
    puts `aws s3 sync #{ENV['HIERA_S3PATH']} /etc/puppetlabs/hieradata/ --delete`
    File.write('/var/local/deployed_hieradata', Time.now.localtime)
  else
    log.warn 'Skip downloading hiera data because HIERA_S3PATH is not set!'
  end
end

# Deploy R10K
def deploy_r10k
  log.info 'Deploy R10K'
  `r10k deploy environment --puppetfile`
  File.write('/var/local/deployed_r10k', Time.now.localtime)
end

# Deployment
def deploy
  download_vault
  download_hieradata
  deploy_r10k
  log.info 'Deployment finished'
end

# Asynchronous Deployment
def async_deploy
  Thread.new { download_vault }
  Thread.new { download_hieradata }
  Thread.new { deploy_r10k }
  log.info 'Deployment started in the background'
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
  return halt 500, 'Signatures did not match!' unless Rack::Utils.secure_compare(signature, env['HTTP_X_HUB_SIGNATURE'])
end

def verify_travis_request
  digest = Digest::SHA2.new.update("#{env['HTTP_TRAVIS_REPO_SLUG']}#{config['travis_token']}")
  return halt 403, 'Unauthorized TravisCI request!' unless digest.to_s == env['HTTP_AUTHORIZATION']
end
