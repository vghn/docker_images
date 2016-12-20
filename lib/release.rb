# Release

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
