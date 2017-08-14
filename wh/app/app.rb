require 'base64'
require 'docker'
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
CONFIG = ENV['API_CONFIG'] || 'config.yml'

# Include helper methods
require './lib/helpers'
extend Helpers
helpers do
  include Helpers
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
  erb :index
end

# Status
get '/status' do
  return 200,  {:status => :success, :message => 'running' }.to_json
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

# Travis webhook
post '/hooks/travis' do
  payload = JSON.parse(params[:payload])
  verify_travis_signature(payload)

  logger.info "Authorized request received from TravisCI build #" \
              "#{payload['number']} for the #{payload['branch']} branch " \
              "of repository #{payload['repository']['name']}"

  deploy_r10k
end

# GitHub webhook
post '/hooks/github' do
  request.body.rewind
  verify_github_signature(request.body.read)
  payload = JSON.parse(params[:payload])

  logger.info 'Authorized request received from GitHub user ' \
              "@#{payload['sender']['login']}"

  # nothing here yet
end

# Slack slash command
post '/hooks/slack' do
  token   = params.fetch('token').strip
  user    = params.fetch('user_name').strip
  channel = params.fetch('channel_name').strip
  command = params.fetch('command').strip
  text    = params.fetch('text').strip

  if token == config['slack_token']
    logger.info "Authorized request received from slacker @#{user} " \
                "on channel ##{channel}"
  else
    logger.warn "Unauthorized token received from slacker @#{user}" \
                "on channel ##{channel}"
  end

  case command
  when '/rhea'
    case text
    when 'deploy'
      # Restrict to specific users
      if config['slack_deploy_users'].include? user
        # Only use the threaded deployment because of the short timeout
        deploy_r10k
        'R10K will deploy in the background :thumbsup:'
      else
        "You are not allowed to deploy R10K :thumbsdown:"
      end
    else
      "I don't understand '#{text}' :cry:"
    end
  else
    "Unknown command '#{command}' :cry:"
  end
end
