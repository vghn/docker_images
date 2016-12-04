require 'spec_helper'

describe 'Dockerfile' do
  include_context 'with a docker container'

  it 'uses the correct version of Ubuntu' do
    os_version = command('cat /etc/lsb-release').stdout
    expect(os_version).to include('16.04')
    expect(os_version).to include('Ubuntu')
  end

  describe package('deluged') do
    it { is_expected.to be_installed }
  end

  describe package('deluge-web') do
    it { is_expected.to be_installed }
  end

  describe command('deluged --version') do
    its(:stdout) { is_expected.to contain('deluged') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe command('deluge-web --version') do
    its(:stdout) { is_expected.to contain('deluge-web') }
    its(:exit_status) { is_expected.to eq 0 }
  end
end
