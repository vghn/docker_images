require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Utils::DockerSharedContext::RunningEntrypointContainer

  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  packages = %w(ca-certificates curl openssl tini)
  packages.each do |pkg|
    describe package(pkg) do
      it { is_expected.to be_installed }
    end
  end

  gems = %w(docker-api faraday json puma sinatra)
  gems.each do |pkg|
    describe package(pkg) do
      it { is_expected.to be_installed.by('gem') }
    end
  end
end
