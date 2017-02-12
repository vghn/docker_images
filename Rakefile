# Configure the load path so all dependencies in your Gemfile can be required
require 'bundler/setup'

# Output module
module Output
  # Colorize output
  module Colorize
    def colorize(color_code)
      "\e[#{color_code}m#{self}\e[0m"
    end

    def red
      colorize(31)
    end

    def green
      colorize(32)
    end

    def blue
      colorize(34)
    end

    def yellow
      colorize(33)
    end
  end

  # Add colorize to the String class
  String.include Colorize

  # Debug message
  def debug(message)
    puts "==> #{message}".green if $DEBUG
  end

  # Information message
  def info(message)
    puts "==> #{message}".green
  end

  # Warning message
  def warn(message)
    puts "==> #{message}".yellow
  end

  # Error message
  def error(message)
    puts "==> #{message}".red
  end
end # module Output

# System module
module System
  # Check if command exists
  def command?(command)
    system("command -v #{command} >/dev/null 2>&1")
  end
end # module System

# Git module
module Git
  GITHUB_TOKEN = ENV['GITHUB_TOKEN']

  # Get git short commit hash
  def git_commit
    `git rev-parse --short HEAD`.strip
  end

  # Get the branch name
  def git_branch
    return ENV['GIT_BRANCH'] if ENV['GIT_BRANCH']
    return ENV['TRAVIS_BRANCH'] if ENV['TRAVIS_BRANCH']
    return ENV['CIRCLE_BRANCH'] if ENV['CIRCLE_BRANCH']
    `git symbolic-ref HEAD --short 2>/dev/null`.strip
  end

  # Get the URL of the origin remote
  def git_url
    `git config --get remote.origin.url`.strip
  end

  # Get the CI Status (needs https://hub.github.com/)
  def git_ci_status(branch = 'master')
    `hub ci-status #{branch}`.strip
  end

  # Check if the repo is clean
  def git_clean_repo
    # Check if there are uncommitted changes
    unless system 'git diff --quiet HEAD'
      abort('ERROR: Commit your changes first.')
    end

    # Check if there are untracked files
    unless `git ls-files --others --exclude-standard`.to_s.empty?
      abort('ERROR: There are untracked files.')
    end

    true
  end
end # module Git

# Version module
module Version
  # Semantic version (from git tags)
  FULL   = (`git describe --always --tags 2>/dev/null`.chomp || '0.0.0-0-0').freeze
  LEVELS = [:major, :minor, :patch].freeze

  # Create semantic version hash
  def semver
    @semver ||= begin
      {}.tap do |h|
        h[:major], h[:minor], h[:patch], h[:rev], h[:rev_hash] = FULL[1..-1].split(/[.-]/)
      end
    end
  end

  # Increment the version number
  def bump(level)
    new_version = semver.dup
    new_version[level] = new_version[level].to_i + 1
    to_zero = LEVELS[LEVELS.index(level) + 1..LEVELS.size]
    to_zero.each { |z| new_version[z] = 0 }
    new_version
  end
end # module Version

# Tasks module
module Tasks
  require 'rake/tasklib'

  # Docker tasks
  class Docker < ::Rake::TaskLib
    # Include utility modules
    include Git
    include Output
    include System
    include Version

    DOCKER_REPOSITORY = ENV['DOCKER_REPOSITORY'] || 'vladgh'
    DOCKER_NO_CACHE   = ENV['DOCKER_NO_CACHE']   || false
    DOCKER_BUILD_ARGS = ENV['DOCKER_BUILD_ARGS'] || true
    DOCKER_BUILD_DATE = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')

    def initialize
      define_tasks
    end

    def define_tasks
      check_docker

      list_images
      garbage_collect

      run_task
      run_task_parallel

      namespace :docker do
        require 'rspec/core/rake_task'

        docker_images.each do |image|
          docker_dir       = File.basename(image)
          docker_image     = "#{DOCKER_REPOSITORY}/#{docker_dir}"
          docker_tag_full  = Version::FULL.to_s
          docker_tag_long  = "#{semver[:major]}.#{semver[:minor]}.#{semver[:patch]}"
          docker_tag_minor = "#{semver[:major]}.#{semver[:minor]}"
          docker_tag_major = "#{semver[:major]}"

          namespace docker_dir.to_sym do |_args|
            RSpec::Core::RakeTask.new(spec: [:docker]) do |task|
              task.pattern = "#{docker_dir}/spec/*_spec.rb"
            end

            desc 'Run Hadolint against the Dockerfile'
            task lint: :docker do
              info "Running Hadolint to check the style of #{docker_dir}/Dockerfile"
              sh "docker run --rm -i lukasmartinelli/hadolint hadolint --ignore DL3008 --ignore DL3013 - < #{docker_dir}/Dockerfile"
            end

            desc 'Build docker image'
            task build: :docker do
              cmd = "cd #{docker_dir} && docker build"

              if DOCKER_BUILD_ARGS
                cmd += " --build-arg VERSION=#{docker_tag_full}"
                cmd += " --build-arg VCS_URL=#{git_url}"
                cmd += " --build-arg VCS_REF=#{git_commit}"
                cmd += " --build-arg BUILD_DATE=#{DOCKER_BUILD_DATE}"
              end

              if DOCKER_NO_CACHE
                info "Ignoring layer cache for #{docker_image}"
                cmd += ' --no-cache'
              end

              info "Building #{docker_image}:#{docker_tag_full}"
              sh "#{cmd} -t #{docker_image}:#{docker_tag_full} ."

              next unless git_branch == 'master' && ENV['TRAVIS_PULL_REQUEST'] == 'false'
              info "Tagging #{docker_image}:#{docker_tag_long} image"
              sh "cd #{docker_dir} && docker tag #{docker_image}:#{docker_tag_full} \
                #{docker_image}:#{docker_tag_long}"

              info "Tagging #{docker_image}:#{docker_tag_minor} image"
              sh "cd #{docker_dir} && docker tag #{docker_image}:#{docker_tag_full} \
                #{docker_image}:#{docker_tag_minor}"

              info "Tagging #{docker_image}:#{docker_tag_major} image"
              sh "cd #{docker_dir} && docker tag #{docker_image}:#{docker_tag_full} \
                #{docker_image}:#{docker_tag_major}"

              info "Tagging #{docker_image}:latest"
              sh "cd #{docker_dir} && docker tag #{docker_image}:#{docker_tag_full} \
                #{docker_image}:latest"
            end # task build

            desc 'Publish docker image'
            task push: :docker do
              next unless ENV['TRAVIS_PULL_REQUEST'] == 'false'
              info "Pushing #{docker_image}:#{docker_tag_full} to Docker Hub"
              sh "docker push #{docker_image}:#{docker_tag_full}"

              next unless git_branch == 'master'
              info "Pushing #{docker_image}:#{docker_tag_long} to Docker Hub"
              sh "docker push #{docker_image}:#{docker_tag_long}"

              info "Pushing #{docker_image}:#{docker_tag_minor} to Docker Hub"
              sh "docker push #{docker_image}:#{docker_tag_minor}"

              info "Pushing #{docker_image}:#{docker_tag_major} to Docker Hub"
              sh "docker push #{docker_image}:#{docker_tag_major}"

              info "Pushing #{docker_image}:latest to Docker Hub"
              sh "docker push #{docker_image}:latest"
            end
          end # task push
        end # docker_images.each
      end # namespace :docker
    end # def define_tasks

    # Run a task for all images
    def run_task
      [:spec].each do |task_name|
        desc "Run #{task_name} for all images in repository"
        task task_name => docker_images
          .collect { |image| "docker:#{File.basename(image)}:#{task_name}" }
      end
    end

    # Run a task for all images in parallel
    def run_task_parallel
      [:lint, :build, :push].each do |task_name|
        desc "Run #{task_name} for all images in repository in parallel"
        multitask task_name => docker_images
          .collect { |image| "docker:#{File.basename(image)}:#{task_name}" }
      end
    end

    # List all folders containing Dockerfiles
    def docker_images
      @docker_images = Dir.glob('*').select do |dir|
        File.directory?(dir) && File.exist?("#{dir}/Dockerfile")
      end
    end

    # Check Docker is installed
    def check_docker
      task :docker do
        raise 'These tasks require docker to be installed' unless command? 'docker'
      end
    end

    # List all images
    def list_images
      namespace :docker do
        desc 'List all Docker images'
        task :list do
          info docker_images.map { |image| File.basename(image) }
        end
      end
    end

    # Garbage collect
    def garbage_collect
      namespace :docker do
        desc 'Garbage collect unused docker filesystem layers'
        task gc: :docker do
          sh 'docker image prune'
        end
      end
    end
  end # class Lint
end # module Tasks

# Tasks module
module Tasks
  require 'rake/tasklib'

  # Lint tasks
  class Lint < ::Rake::TaskLib
    def initialize
      define_tasks
    end

    def define_tasks
      # RuboCop
      require 'rubocop/rake_task'
      desc 'Run RuboCop on the tasks and lib directory'
      RuboCop::RakeTask.new(:rubocop) do |task|
        task.patterns = lint_files_list
        task.options  = ['--display-cop-names', '--extra-details']
      end

      # Reek
      require 'reek/rake/task'
      Reek::Rake::Task.new do |task|
        task.source_files  = lint_files_list
        task.fail_on_error = false
        task.reek_opts     = '--wiki-links --color'
      end

      # Ruby Critic
      require 'rubycritic/rake_task'
      RubyCritic::RakeTask.new do |task|
        task.paths = lint_files_list
      end
    end # def define_tasks

    # Compose a list of Ruby files
    def lint_files_list
      @lint_files_list ||= FileList[
        'lib/**/*.rb',
        'spec/**/*.rb',
        'Rakefile'
      ].exclude('spec/fixtures/**/*')
    end
  end # class Lint
end # module Tasks

# Tasks module
module Tasks
  require 'rake/tasklib'

  # Release tasks
  class Release < ::Rake::TaskLib
    # Include utility modules
    include Git
    include Output
    include Version

    def initialize
      define_tasks
    end

    # Configure the github_changelog_generator/task
    def changelog(config, release: nil)
      config.bug_labels         = 'Type: Bug'
      config.enhancement_labels = 'Type: Enhancement'
      config.future_release     = "v#{release}" if release
    end

    def define_tasks
      begin
        require 'github_changelog_generator/task'
        GitHubChangelogGenerator::RakeTask.new(:unreleased) do |config|
          changelog(config)
        end
      rescue LoadError
        nil # Might be in a group that is not installed
      end

      namespace :release do
        Version::LEVELS.each do |level|
          desc "Increment #{level} version"
          task level.to_sym do
            new_version = bump(level)
            release = "#{new_version[:major]}.#{new_version[:minor]}.#{new_version[:patch]}"
            release_branch = "release_v#{release.gsub(/[^0-9A-Za-z]/, '_')}"
            initial_branch = git_branch

            info 'Check if the repository is clean'
            git_clean_repo

            einfo 'Create a new release branch'
            sh "git checkout -b #{release_branch}"

            info 'Generate new changelog'
            GitHubChangelogGenerator::RakeTask.new(:latest_release) do |config|
              changelog(config, release: release)
            end
            Rake::Task['latest_release'].invoke

            info 'Push the new changes'
            sh "git commit --gpg-sign --message 'Update change log for v#{release}' CHANGELOG.md"
            sh "git push --set-upstream origin #{release_branch}"

            info 'Waiting for CI to finish'
            puts 'Waiting for CI to finish'
            sleep 5 until git_ci_status(release_branch) == 'success'

            info 'Merge release branch'
            sh "git checkout #{initial_branch}"
            sh "git merge --gpg-sign --no-ff --message 'Release v#{release}' #{release_branch}"

            info 'Tag release'
            sh "git tag --sign v#{release} --message 'Release v#{release}'"
            sh 'git push --follow-tags'
          end
        end
      end
    end # def define_tasks
  end # class Release
end # module Tasks

# Tasks module
module Tasks
  require 'rake/tasklib'

  # Release tasks
  class TravisCI < ::Rake::TaskLib
    # Include utility modules
    include Output

    require 'dotenv'

    begin
      require 'travis/auto_login'
    rescue LoadError
      nil # Might be in a group that is not installed
    end

    def initialize
      define_tasks
    end

    def define_tasks
      desc 'Sync environment with TravisCI'
      task :sync_travis_env do
        info "Hello #{Travis::User.current.name}!"

        # Update environment variables
        dotenv.each do |key, value|
          info "Updating #{key}"
          env_vars.upsert(key, value, public: false)
        end

        # Remove remote environment variables
        env_vars.each do |var|
          unless dotenv.keys.include?(var.name)
            warn "Deleting #{var.name}"
            var.delete
          end
        end
      end
    end # def define_tasks

    def travis_slug
      @travis_slug ||= `git config --get travis.slug`.chomp
    end

    def env_vars
      @env_vars ||= Travis::Repository.find(travis_slug).env_vars
    end

    def dotenv
      @dotenv ||= Dotenv.load
    end
  end # class TravisCI
end # module Tasks

# Include task modules
Tasks::Docker.new
Tasks::Lint.new
Tasks::Release.new
Tasks::TravisCI.new

# Display version
desc 'Display version'
task :version do
  puts "Current version: #{Version::FULL}"
end

# Create a list of contributors from GitHub
desc 'Populate CONTRIBUTORS file'
task :contributors do
  system("git log --format='%aN' | sort -u > CONTRIBUTORS")
end

# List all tasks by default
Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task :default do
  system 'rake -D'
end
