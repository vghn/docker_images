require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Utils::DockerSharedContext::Container
  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  packages = %w(rsyslog rsyslog-tls tini tzdata)
  packages.each do |pkg|
    describe package(pkg) do
      it { is_expected.to be_installed }
    end
  end

  describe file('/etc/rsyslog.conf') do
    it { is_expected.to exist }
  end

end
