require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a docker container'

  describe package('haproxy') do
    it { is_expected.to be_installed }
  end

  describe command('haproxy --version') do
    its(:stdout) { is_expected.to match(/haproxy/) }
  end
end
