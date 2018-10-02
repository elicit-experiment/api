source 'https://rubygems.org'

ruby '2.5.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.0'
gem 'webpacker'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'uglifier'

# for respond_to
gem 'responders'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
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
gem 'swagger-blocks', '1.3.1'
gem 'swagger_ui_engine'
gem 'rspec-rails'
gem 'apivore'

# authentication
gem 'devise', '~> 4.3.0'
gem 'doorkeeper'
gem 'devise-doorkeeper'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'mocha'
end

group :development do
  gem 'rails-erd', require: false, group: :development
  gem 'pry'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


#for _toxml to work. edit: replaced with activemodel-serializers-xml
#gem 'activesupport'
# To continue using XML serialization in your application
gem 'activemodel-serializers-xml'
# To be able to parse XML post_params in your application
gem 'actionpack-xml_parser'

group :production do
  gem 'pg'
end

gem 'lograge', '~> 0.4'
gem 'logstash-event'

gem 'json-schema'
gem 'json-schema-generator'

gem 'carrierwave'
gem 'carrierwave-base64'


