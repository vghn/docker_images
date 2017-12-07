require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Utils::DockerSharedContext::RunningEntrypointContainer

  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  packages = %w(bash certbot openssl py2-future tini)
  packages.each do |pkg|
    describe package(pkg) do
      it { is_expected.to be_installed }
    end
  end

  describe command('certbot --version') do
    its(:stderr) { is_expected.to match(/certbot/) }
  end

  describe command('certbot plugins') do
    its(:stdout) { is_expected.to contain(/\* dns-cloudflare/) }
  end
end
