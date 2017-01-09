require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a docker container (override entrypoint)'

  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  describe package('curl') do
    it { is_expected.to be_installed }
  end

  describe package('findutils') do
    it { is_expected.to be_installed }
  end

  describe command('find --version') do
    its(:stdout) { is_expected.to contain('(GNU findutils)') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe package('git') do
    it { is_expected.to be_installed }
  end

  describe command('git version') do
    its(:stdout) { is_expected.to contain('git') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  ['faraday', 'json', 'puma', 'r10k', 'sinatra'].each do |gem|
    describe package(gem) do
      it { is_expected.to be_installed.by('gem') }
    end
  end
end
