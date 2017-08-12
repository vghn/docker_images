# Add libraries to the load path
$LOAD_PATH.unshift(File.dirname(__FILE__))

# Run classic app
require './app'
run Sinatra::Application
