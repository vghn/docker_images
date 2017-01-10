ENV['RACK_ENV'] = 'test'

def app
  @app ||= Rack::Builder.parse_file('config.ru').first
end

require 'rack/test'
require 'rspec'
RSpec.configure do |config|
  # Abort the run on first failure.
  config.fail_fast = true
  # Use color in STDOUT
  config.color = true
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true
  # Show test times
  config.profile_examples = true
  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate
  # Include Rack-Test
  config.include Rack::Test::Methods
end
