require 'spec_helper'

describe 'API' do
  before(:each) do
    env 'HTTPS', 'on'
  end

  it 'should redirect HTTP to HTTPS' do
    env 'HTTPS', nil
    get '/'
    expect(last_response.redirect?).to be true
    expect(last_response.headers['Location']).to eq('https://example.org/')
  end

  it 'should allow accessing the home page' do
    get '/'
    expect(last_response).to be_ok
  end

  it 'should allow accessing the status page' do
    get '/status'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Alive')
  end
end
