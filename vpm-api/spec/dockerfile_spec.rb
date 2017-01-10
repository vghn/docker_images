require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a docker container (override entrypoint)'

  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  packages = %w(ca-certificates curl findutils git groff less openssl python)
  packages.each do |pkg|
    describe package(pkg) do
      it { is_expected.to be_installed }
    end
  end

  gems = %w(faraday json puma r10k sinatra)
  gems.each do |pkg|
    describe package(pkg) do
      it { is_expected.to be_installed.by('gem') }
    end
  end

  describe command('aws --version') do
    its(:stderr) { is_expected.to contain('aws-cli') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe command('docker --version') do
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe command('find --version') do
    its(:stdout) { is_expected.to contain('(GNU findutils)') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe command('git version') do
    its(:stdout) { is_expected.to contain('git') }
    its(:exit_status) { is_expected.to eq 0 }
  end
end
