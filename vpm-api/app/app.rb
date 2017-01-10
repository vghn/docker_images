require 'sinatra'

# Sinatra Application Class
class API < Sinatra::Application
  # VARs
  set :config_file, ENV['API_CONFIG']
  set :secure_s3path, ENV['SECURE_S3PATH']
  set :hiera_s3path, ENV['HIERA_S3PATH']
  set :control_repo, ENV['CONTROL_REPO']

  # Add helpers
  require 'app_helpers'
  extend APPHelpers

  # Flush output immediately
  $stdout.sync = true

  # Logging
  enable :logging

  # Production settings
  configure :production do
    logger.level = Logger::INFO
  end

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
        ENV.each.map { |k, v| "<li><b>#{k}:</b> #{v}</li>" }.join + '</ul>'
    end
  end

  # Status
  get '/status' do
    'Alive'
  end
end # class API
