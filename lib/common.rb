require 'rainbow'

def version
  File.read('VERSION').strip
end

def git_commit
  `git rev-parse --short HEAD`.strip
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
