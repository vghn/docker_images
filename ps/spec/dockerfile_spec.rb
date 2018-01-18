require 'spec_helper'

describe 'Dockerfile' do
  before(:all) do
    @image = ::Docker::Image.build_from_dir(File.dirname(File.dirname(__FILE__)))
    set :backend, :docker
    set :docker_image, @image.id
    set :docker_container_create_options, {'Healthcheck' => {'Test' => ['NONE']}}
  end

  it "should have the maintainer label" do
    expect(@image.json["Config"]["Labels"].has_key?("maintainer"))
  end

  describe package('aws-sdk-ec2') do
    it { is_expected.to be_installed.by('gem') }
  end

  describe file('/usr/local/bin/csr-sign') do
    it { is_expected.to exist }
    it { is_expected.to be_executable }
  end
end
