require 'spec_helper'

describe 'Sinatra::Application' do
  let(:repo) { 'https://example.com/repo.git' }
  let(:r10k_cfg)  { '/tmp/tests/r10k_test' }

  before(:each) do
    stub_const('CONTROL_REPO', repo)
    stub_const('R10K_CFG_FILE', r10k_cfg)
  end

  it 'should allow accessing the home page' do
    get '/'
    expect(last_response).to be_ok
  end

  it 'should allow accessing the status page' do
    get '/status'
    expect(last_response).to be_ok
    expect(last_response.body).to match('Alive')
  end

  it 'should return valid R10K template' do
    expect(r10k_template).to match('sources')
  end

  it 'should parse R10K template' do
    expect(r10k_config).to match(repo)
  end

  it 'should write R10K configration' do
    expect(write_r10k_config).to be true
    expect(File.read(r10k_cfg)).to match(repo)
  end

  it 'should check R10K configration' do
    expect(check_r10k_config).to be true
  end
end
