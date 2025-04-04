# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#

require 'dotenv'

# For local testing, try to replicate the Dotenv::Rails files list, since this needs to get loaded first and preempts
# Dotenv::Rails' configuration. We need to expand the env variables here so we can consume them here, before rails starts.
def configure_dotenv
  files = [
    (".env.#{ENV['RAILS_ENV']}.local" if ENV['RAILS_ENV']),
    ".env"
  ].compact

  Dotenv.load(*files)
end

configure_dotenv

max_threads_count = Integer(ENV.fetch('RAILS_MAX_THREADS', 5))
min_threads_count = Integer(ENV.fetch('RAILS_MIN_THREADS', max_threads_count))
threads min_threads_count, max_threads_count

# You can either set the env var, or check for development
if ENV.fetch('SOLID_QUEUE_IN_PUMA', 'false') == 'true' && ENV.fetch('ENABLE_SOLID_QUEUE', 'false') == 'true'
  plugin :solid_queue
end

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
#
worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port Integer(ENV.fetch('PORT', 3000))

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch('RAILS_ENV', 'development')

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
web_concurrency = Integer(ENV.fetch('WEB_CONCURRENCY', 1))
workers web_concurrency if web_concurrency > 1

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
preload_app! if web_concurrency > 1

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
