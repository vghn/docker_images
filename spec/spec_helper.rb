require 'serverspec'
require 'docker'

# VARs
CURRENT_DIRECTORY = File.dirname(File.dirname(__FILE__))

# Travis builds can take time
Docker.options[:read_timeout] = 7200

# Docker image context
shared_context 'shared docker image' do
  before(:all) do
    @image = Docker::Image.build_from_dir(CURRENT_DIRECTORY)
    set :backend, :docker
  end
end

# Docker container context
shared_context 'with a docker container' do
  include_context 'shared docker image'

  before(:all) do
    @container = Docker::Container.create('Image' => @image.id)
    @container.start

    set :docker_container, @container.id
  end

  after(:all) do
    @container.kill
    @container.delete(force: true)
  end
end

# Docker always running container
shared_context 'with a perpetual docker container' do
  include_context 'shared docker image'

  before(:all) do
    @container = Docker::Container.create(
      'Image' => @image.id,
      'Entrypoint' => ['sh', '-c', 'while true; do sleep 1; done']
    )
    @container.start

    set :docker_container, @container.id
  end

  after(:all) do
    @container.kill
    @container.delete(force: true)
  end
end
