require 'spec_helper'

describe 'Dockerfile' do
  before(:all) do
    @image = ::Docker::Image.build_from_dir(File.dirname(File.dirname(__FILE__)))
    set :backend, :docker
    set :docker_image, @image.id
    set :docker_container_create_options, 'Entrypoint' => ['sh']
  end

  it "should have the maintainer label" do
    expect(@image.json["Config"]["Labels"].has_key?("maintainer"))
  end

  describe file('/usr/local/share/ca-certificates/VladGhCARoot.crt') do
    it { is_expected.to exist }
  end

  describe file('/etc/ssl/certs/ca-cert-VladGhCARoot.pem') do
    it { is_expected.to be_symlink }
    it { is_expected.to be_linked_to '/usr/local/share/ca-certificates/VladGhCARoot.crt' }
  end
end
