require 'spec_helper'

describe 'Dockerfile' do
  include_context 'with a perpetual docker container'

  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  describe package('minidlna') do
    it { is_expected.to be_installed }
  end

  describe command('minidlnad -V') do
    its(:stdout) { is_expected.to contain('Version') }
    its(:exit_status) { is_expected.to eq 0 }
  end
end
