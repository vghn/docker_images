require 'erb'
require 'fileutils'
require 'yaml'

# R10K methods
module R10K
  # R10K configuration template
  def r10k_template
    <<-EOT
# The location to use for storing cached Git repos
cachedir: '/opt/puppetlabs/r10k/cache'

# A list of git repositories to create
sources:
  # This will clone the git repository and instantiate an environment per
  # branch in /etc/puppetlabs/code/environments
  main:
    remote: '<%= control_repo %>'
    basedir: '/etc/puppetlabs/code/environments'
    EOT
  end

  # R10K configuration
  def r10k_config
    @r10k_config ||= ERB.new(r10k_template).result(binding)
  end

  # Generate R10K configuration
  def write_r10k_config
    logger.info 'Generate R10K configuration'
    FileUtils.mkdir_p(File.dirname(r10k_config_file))
    File.write(r10k_config_file, r10k_config)
    logger.info 'R10K configuration created'
  end

  # Check R10K configuration
  def check_r10k_config
    if File.exist?(r10k_config_file) && \
       File.read(r10k_config_file) == r10k_config
      logger.info 'R10K configuration has not changed'
    else
      write_r10k_config
    end
  end

  # Check R10K deployment
  def deploy_r10k
    if control_repo
      check_r10k_config
      run_r10k_deploy
    else
      logger.warn 'Skip R10K deployment because CONTROL_REPO is not set!'
    end
  end

  # Deploy R10K
  def run_r10k_deploy
    logger.info 'Deploy R10K'
    logger.debug `r10k deploy environment --puppetfile`
    File.write('/var/local/deployed_r10k', Time.now.localtime)
    logger.info 'R10K deployed'
  end
end # module R10K
