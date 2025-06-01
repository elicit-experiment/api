# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.4.4'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'net-smtp', require: false

gem 'rails', '~> 7'
# 6.0 is incompatible with swagger_ui_engine https://github.com/zuzannast/swagger_ui_engine/issues/43
gem 'shakapacker', '~> 8'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'aws-sdk-s3', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'puma', '~> 6.4'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'uglifier'

# for respond_to
gem 'responders'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.13'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'awesome_print'

# CORS...
gem 'rack-cors'

# pagination!
gem 'kaminari'

# for api doc
# gem 'apivore'
gem 'rspec-rails'
gem 'swagger-blocks', '~> 3'
# gem 'swagger_ui_engine', git: 'https://github.com/azelenets/swagger_ui_engine'
gem 'swagger_ui_engine', path: 'gems/swagger_ui_engine'

# authentication
gem 'cancancan'
gem 'devise', '~> 4.7'
gem 'devise-doorkeeper'
gem 'doorkeeper'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'mocha'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :development do
  gem 'rails-erd', require: false, group: :development
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  # gem 'spring'
  gem 'listen'
end

group :test do
  gem 'capybara', '~> 3.33'
  gem 'fakefs', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# for _toxml to work. edit: replaced with activemodel-serializers-xml
# gem 'activesupport'
# To continue using XML serialization in your application
gem 'activemodel-serializers-xml'
# To be able to parse XML post_params in your application
gem 'actionpack-xml_parser'

group :production do
  gem 'newrelic_rpm', '~> 9.16'
  gem 'pg', '~> 1.5'
end

gem 'lograge'
gem 'lograge-sql', '~> 2.0'
gem 'logstash-event'

gem 'json-schema'
gem 'json-schema-generator'

gem 'carrierwave'
gem 'carrierwave-base64'

gem 'rack-mini-profiler', require: false

# gem 'flamegraph', '~> 0.9.5', require: false
# gem 'memory-profiler', '~> 1.0', require: false
# gem 'stackprof', '~> 0.2.12', require: false

gem 'dotenv', '~> 3.0'

gem 'csv', '~> 3.3'

gem 'mutex_m', '~> 0.3.0'

gem 'redis-client'

gem 'solid_queue', '~> 1.1.4'

gem 'activerecord-import', '~> 2.1'

# Email sending via Mailgun
gem 'mailgun-ruby', '~> 1.2'
