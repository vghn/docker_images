require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a docker container (override entrypoint)'

  describe command('certbot --version') do
    its(:stderr) { is_expected.to match(/certbot/) }
  end
end
