require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a docker container'

  describe package('aws-sdk') do
    it { is_expected.to be_installed.by('gem') }
  end
end
