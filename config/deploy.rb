# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.11.0'

set :application, 'elicit'
set :repo_url, 'https://lab.compute.dtu.dk/elicit/api.git'
set :fe_repo_url, 'git@lab.compute.dtu.dk:elicit/experiment-frontend.git'
set :git_https_username, 'iaibrys'
set :git_https_password, 'Ht6ge3E9'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/elicit"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

desc 'Build Docker images'
task :build do
  # build the actual docker image, tagging the push for the remote repo
  on roles(:app) do
    within release_path do
      execute "ln -s #{release_path}'/.env-prod cd '#{release_path}'/.env"
      execute "cd '#{release_path}' && docker-compose build"
    end
  end
end

desc 'go'
task go: %w[build deploy]

desc 'deploy'
task :deploy do
  on roles(:app) do
    Rake::Task['deploy:restart'].invoke
  end
end

namespace :deploy do
  task :restart do
    on roles(:app) do
      execute "ln -s '#{release_path}/.env-prod' '#{release_path}/.env'"
      execute "cd '#{release_path}' && docker-compose build"

      # in case the app isn't running on the other end
      execute "cd '#{release_path}' && docker-compose down ; true"

      # modify this to suit how you want to run your app
      execute "cd '#{release_path}' && docker-compose up -d ; true"
    end
  end
end
