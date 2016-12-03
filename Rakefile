require 'rainbow'

# VARs
REPOSITORY   = ENV['DOCKER_REPOSITORY']   || 'vladgh'
NO_CACHE     = ENV['DOCKER_NO_CACHE']     || false
BUILD_ARGS   = ENV['DOCKER_BUILD_ARGS']   || true

# Internals
BUILD_DATE = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
IMAGES = Dir.glob('*').select do |dir|
  File.directory?(dir) && File.exist?("#{dir}/Dockerfile")
end

def info(message)
  puts Rainbow("==> #{message}").green
end

def warn(message)
  puts Rainbow("==> #{message}").yellow
end

def error(message)
  puts Rainbow("==> #{message}").red
end

# Check if command exists
def command?(command)
  system("command -v #{command} >/dev/null 2>&1")
end

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
def ci_status(branch = 'master')
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

# Get version number from git tags
def version
  `git describe --always --tags`.strip
end

# Split the version number
def version_hash
  @version_hash ||= begin
    {}.tap do |h|
      h[:major], h[:minor], h[:patch], h[:rev], h[:rev_hash] = version[1..-1].split(/[.-]/)
    end
  end
end

# Increment the version number
def version_increment(level)
  v = version_hash.dup
  v[level] = v[level].to_i + 1
  to_zero = LEVELS[LEVELS.index(level) + 1..LEVELS.size]
  to_zero.each { |z| v[z] = 0 }
  v
end

# Configure the github_changelog_generator/task
def configure_changelog(config, release: nil)
  config.bug_labels         = 'Type: Bug'
  config.enhancement_labels = 'Type: Enhancement'
  config.future_release     = "v#{release}" if release
end

# RSpec
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = '--format documentation --color'
end

# RuboCop
require 'rubocop/rake_task'
desc 'Run RuboCop on the tasks and lib directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = FileList['{lib,rakelib,spec}/**/*.{rb,rake}', 'Rakefile']
end

# Reek
require 'reek/rake/task'
Reek::Rake::Task.new do |task|
  task.source_files  = FileList['{lib,rakelib,spec}/**/*.{rb,rake}', 'Rakefile']
  task.fail_on_error = false
  task.reek_opts     = '-U'
end

# Ruby Critic
require 'rubycritic/rake_task'
RubyCritic::RakeTask.new do |task|
  task.paths = FileList['{lib,rakelib,spec}/**/*.{rb,rake}', 'Rakefile']
end

# GitHub CHANGELOG generator
require 'github_changelog_generator/task'
GitHubChangelogGenerator::RakeTask.new(:unreleased) do |config|
  configure_changelog(config)
end

# Release task
namespace :release do
  LEVELS = [:major, :minor, :patch].freeze
  LEVELS.each do |level|
    desc "Increment #{level} version"
    task level.to_sym do
      v = version_increment(level)
      release = "#{v[:major]}.#{v[:minor]}.#{v[:patch]}"
      release_branch = "release_v#{release.gsub(/[^0-9A-Za-z]/, '_')}"
      initial_branch = git_branch

      # Check if the repo is clean
      git_clean_repo

      # Create a new release branch
      sh "git checkout -b #{release_branch}"

      # Generate new changelog
      GitHubChangelogGenerator::RakeTask.new(:latest_release) do |config|
        configure_changelog(config, release: release)
      end
      Rake::Task['latest_release'].invoke

      # Push the new changes
      sh "git commit --gpg-sign --message 'Release v#{release}' CHANGELOG.md"
      sh "git push --set-upstream origin #{release_branch}"

      # Waiting for CI to finish
      puts 'Waiting for CI to finish'
      sleep 5 until ci_status(release_branch) == 'success'

      # Merge release branch
      sh "git checkout #{initial_branch}"
      sh "git merge --gpg-sign --no-ff --message 'Release v#{release}' #{release_branch}"

      # Tag release
      sh "git tag --sign v#{release} --message 'Release v#{release}'"
      sh 'git push --follow-tags'
    end
  end
end

task :docker do
  raise 'These tasks require docker to be installed' unless command? 'docker'
end

desc 'List all Docker images'
task :list do
  info IMAGES.map { |image| File.basename(image) }
end

desc 'Garbage collect unused docker filesystem layers'
task gc: :docker do
  unless `docker images -f "dangling=true" -q`.empty?
    sh 'docker rmi $(docker images -f "dangling=true" -q)'
  end
end

IMAGES.each do |image|
  docker_dir       = File.basename(image)
  docker_image     = "#{REPOSITORY}/#{docker_dir}"
  docker_tag       = version.to_s
  docker_tag_short = "#{version_hash[:major]}.#{version_hash[:minor]}.#{version_hash[:patch]}"

  namespace docker_dir.to_sym do |_args|
    RSpec::Core::RakeTask.new(spec: [:docker]) do |t|
      t.pattern = "#{docker_dir}/spec/*_spec.rb"
    end

    desc 'Run Hadolint against the Dockerfile'
    task lint: :docker do
      info "Running Hadolint to check the style of #{docker_dir}/Dockerfile"
      sh "docker run --rm -i lukasmartinelli/hadolint hadolint --ignore DL3008 --ignore DL3013 - < #{docker_dir}/Dockerfile"
    end

    desc 'Build docker image'
    task build: :docker do
      cmd = "cd #{docker_dir} && docker build"

      if BUILD_ARGS
        cmd += " --build-arg VERSION=#{docker_tag}"
        cmd += " --build-arg VCS_URL=#{git_url}"
        cmd += " --build-arg VCS_REF=#{git_commit}"
        cmd += " --build-arg BUILD_DATE=#{BUILD_DATE}"
      end

      if NO_CACHE
        info "Ignoring layer cache for #{docker_image}"
        cmd += ' --no-cache'
      end

      info "Building #{docker_image}:#{docker_tag}"
      sh "#{cmd} -t #{docker_image}:#{docker_tag} ."

      info "Tagging #{docker_image}:#{docker_tag_short}"
      sh "cd #{docker_dir} && docker tag #{docker_image}:#{docker_tag} #{docker_image}:#{docker_tag_short}"

      case git_branch
      when 'master'
        info "Tagging #{docker_image}:latest"
        sh "cd #{docker_dir} && docker tag #{docker_image}:#{docker_tag} #{docker_image}:latest"
      else
        info "Tagging #{docker_image}:#{git_branch}"
        sh "cd #{docker_dir} && docker tag #{docker_image}:#{docker_tag} #{docker_image}:#{git_branch}"
      end
    end

    desc 'Publish docker image'
    task push: :docker do
      info "Pushing #{docker_image}:#{docker_tag} to Docker Hub"
      sh "docker push '#{docker_image}:#{docker_tag}'"

      info "Pushing #{docker_image}:#{docker_tag_short} to Docker Hub"
      sh "docker push '#{docker_image}:#{docker_tag_short}'"

      case git_branch
      when 'master'
        info "Pushing #{docker_image}:latest to Docker Hub"
        sh "docker push '#{docker_image}:latest'"
      else
        info "Pushing #{docker_image}:#{git_branch} to Docker Hub"
        sh "docker push '#{docker_image}:#{git_branch}'"
      end
    end
  end
end

[:lint, :build, :push].each do |task_name|
  desc "Run #{task_name} for all images in repository in parallel"
  multitask task_name => IMAGES
    .collect { |image| "#{File.basename(image)}:#{task_name}" }
end

[:spec].each do |task_name|
  desc "Run #{task_name} for all images in repository"
  task task_name => IMAGES
    .collect { |image| "#{File.basename(image)}:#{task_name}" }
end

# Test everything
desc 'Run all tests.'
task test: [
  :rubocop,
  :lint,
  :spec
]

# List all tasks by default
task :default do
  puts `rake -T`
end

# Version
desc 'Display version'
task :version do
  puts "Current version: #{version}"
end
