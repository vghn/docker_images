require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Utils::DockerSharedContext::RunningEntrypointContainer

  describe file('/usr/local/share/ca-certificates/VladGhCARoot.crt') do
    it { is_expected.to exist }
  end

  describe file('/etc/ssl/certs/ca-cert-VladGhCARoot.pem') do
    it { is_expected.to be_symlink }
    it { is_expected.to be_linked_to '/usr/local/share/ca-certificates/VladGhCARoot.crt' }
  end
end
