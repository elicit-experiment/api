#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'securerandom'

# Only this demo entrypoint supplies these defaults; normal deployments are unchanged.
root = File.expand_path('../..', __dir__)
Dir.chdir(root)
ENV['ELICIT_DEMO'] = 'true'
ENV['RAILS_ENV'] = 'production'
ENV['DATABASE_ADAPTER'] = 'sqlite3'
%w[DATABASE_URL PRIMARY_DATABASE_URL QUEUE_DATABASE_URL].each { |key| ENV.delete(key) }
state = ENV.fetch('ELICIT_DEMO_DATA', File.join(root, 'storage/demo'))
FileUtils.mkdir_p(state)
credentials_file = File.join(state, 'credentials.json')
role = ARGV.shift || 'web'
abort 'Expected web, jobs, credentials, assets, or run COMMAND...' unless %w[web jobs credentials assets run].include?(role)

if role == 'credentials'
  credentials = JSON.parse(File.read(credentials_file))
  puts "Admin email: admin@elicit.com\nAdmin username: admin\nAdmin password: #{credentials.fetch('ADMIN_PASSWORD')}"
  exit
end

File.open(File.join(state, '.credentials.lock'), File::RDWR | File::CREAT, 0o600) do |lock|
  lock.flock(File::LOCK_EX)
  unless File.exist?(credentials_file)
    credentials = %w[SECRET_KEY_BASE ADMIN_PASSWORD SUBJECT_DEFAULT_PASSWORD].to_h { |key| [key, SecureRandom.hex(32)] }
    temporary = "#{credentials_file}.tmp"
    File.open(temporary, File::WRONLY | File::CREAT | File::TRUNC, 0o600) { |file| file.write(JSON.generate(credentials)) }
    File.rename(temporary, credentials_file)
  end
end
ENV.update(JSON.parse(File.read(credentials_file)))
ENV['SUBJECT_PASSWORD_DEFAULT'] = ENV.fetch('SUBJECT_DEFAULT_PASSWORD') # Upstream seed spelling.
ENV['SQLITE_DATABASE_DIR'] = state
ENV['API_SCHEME'] = ENV['EXTERNAL_API_SCHEME'] = 'http'
ENV['SITE_SUFFIX'] = ENV.fetch('ELICIT_DEMO_HOST', 'localhost')
ENV['API_URL'] = ENV['ELICIT_URL'] = "#{ENV.fetch('ELICIT_DEMO_HOST', 'localhost')}:#{ENV.fetch('ELICIT_DEMO_PORT', '8080')}"
ENV['PUBLIC_CLIENT_ID'] = 'admin_public'
ENV['PUBLIC_CLIENT_SECRET'] = 'elicit-demo-public-admin'
ENV['WEBAPP_CLIENT_ID'] = 'webapp_public'
ENV['WEBAPP_CLIENT_SECRET'] = 'elicit-demo-public-webapp'
ENV['ADMIN_USER'] = 'admin'
ENV['REDIS_PASSWORD'] = 'unused-demo-does-not-use-redis'
ENV['ENABLE_SOLID_QUEUE'] = 'true'
ENV['RAILS_SERVE_STATIC_FILES'] = 'true'
ENV['SHAKAPACKER_PRECOMPILE'] = 'false'
ENV['NEW_RELIC_AGENT_ENABLED'] = 'false'
FileUtils.mkdir_p('tmp/pids')

case role
when 'web'
  # db:prepare seeds a fresh database, and is safe to repeat on subsequent boots.
  abort 'Database preparation failed' unless system('bundle', 'exec', 'rails', 'db:prepare')
  exec('bundle', 'exec', 'puma', '-C', 'config/puma.rb', '-b', 'tcp://0.0.0.0:3000')
when 'jobs'
  exec('bundle', 'exec', 'ruby', 'bin/jobs')
when 'assets'
  exec('bundle', 'exec', 'rails', 'assets:precompile')
when 'run'
  abort 'run requires a command' if ARGV.empty?
  exec(*ARGV)
end
