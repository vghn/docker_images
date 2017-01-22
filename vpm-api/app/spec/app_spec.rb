require 'spec_helper'

describe 'Sinatra::Application' do
  it 'should allow accessing the home page' do
    get '/'
    expect(last_response).to be_ok
  end

  it 'should allow accessing the status page' do
    get '/status'
    expect(last_response).to be_ok
    expect(last_response.body).to match('Alive')
  end
end
