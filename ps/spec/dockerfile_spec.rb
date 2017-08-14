require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Utils::DockerSharedContext::Container

  describe package('aws-sdk') do
    it { is_expected.to be_installed.by('gem') }
  end

  describe file('/usr/local/bin/csr-sign') do
    it { is_expected.to exist }
    it { is_expected.to be_executable }
  end
end
