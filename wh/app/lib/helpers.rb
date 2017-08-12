module Helpers
  # Logging
  def logger
    @logger ||= Logger.new(STDOUT)
  end

  # Configuration
  def config
    @config ||= YAML.load_file(CONFIG)
  end

  # Filter running containers by service label
  def container(label, value)
    @container = Docker::Container.all(
      all: false,
      filters: {
        label: ["#{label}=#{value}"]
      }.to_json
    )
  rescue Excon::Error::Socket
    logger.warn "Could not connect to docker daemon!"
    return nil
  end

  # Deploy R10K in a separate thread (look for a container labeled with r10k)
  def deploy_r10k
    Thread.new do
      begin
        logger.info 'Deploying R10K environment'
        stdout, stderr, status = container('r10k', 'true').first
          .exec(['r10k', 'deploy', 'environment', '--puppetfile'])
        if status == 0
          logger.info 'Deployment completed'
        else
          raise stdout.join(', ') unless stdout.empty?
          raise stderr.join(', ') unless stderr.empty?
        end
      rescue => error
        logger.warn "Deployment failed (#{error})!"
      end
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
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, config['github_secret'], payload_body)
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
    return @travis_public_key if defined? @travis_public_key

    @conn = Faraday.new(url: 'https://api.travis-ci.org') do |faraday|
      faraday.adapter Faraday.default_adapter
    end
    response = @conn.get '/config'
    JSON.parse(response.body)['config']['notifications']['webhook']['public_key']
  end

  # Initial deployment
  def initial_deployment
    logger.info 'Start initial deployment'
    deploy_r10k
  end
end
