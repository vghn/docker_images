require 'rainbow'

def version
  File.read('VERSION').strip
end

def git_commit
  `git rev-parse --short HEAD`.strip
end

def git_branch
  return ENV['GIT_BRANCH'] if ENV['GIT_BRANCH']
  return ENV['TRAVIS_BRANCH'] if ENV['TRAVIS_BRANCH']
  `git symbolic-ref HEAD --short 2>/dev/null`.strip
end

def git_url
  `git config --get remote.origin.url`.strip
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

def command?(command)
  system("command -v #{command} >/dev/null 2>&1")
end
