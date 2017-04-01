require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Utils::DockerSharedContext::Container

  describe package('aws-sdk') do
    it { is_expected.to be_installed.by('gem') }
  end

  describe command('puppetserver gem list') do
    its(:stdout) { is_expected.to match(/hiera-eyaml/) }
  end
end
