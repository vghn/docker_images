require 'serverspec'
require 'docker'

# VARs
CURRENT_DIRECTORY = File.dirname(File.dirname(__FILE__))

# Travis builds can take time
Docker.options[:read_timeout] = 7200

# Load any shared examples or context helpers
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
