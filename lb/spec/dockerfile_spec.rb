require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Docker::SharedContext::Container

  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  packages = %w(bash inotify-tools tini)
  packages.each do |pkg|
    describe package(pkg) do
      it { is_expected.to be_installed }
    end
  end

  describe command('haproxy --version') do
    its(:stdout) { is_expected.to match(/haproxy/) }
  end

  describe command('inotifywait --help') do
    its(:stdout) { is_expected.to contain('inotifywait') }
    its(:exit_status) { is_expected.to eq 1 }
  end
end
