require_relative 'boot'
require "sprockets/railtie"
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ElicitApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.api_only = false

    config.autoload_paths << "#{Rails.root}/lib"
    config.autoload_paths << "#{Rails.root}/app/services"

    config.elicit = config_for(:elicit_config)


    log_level = String(ENV['LOG_LEVEL'] || "info").upcase
    config.logger = Logger.new(STDOUT)
    config.logger.level = Logger.const_get(log_level)
    config.log_level = log_level

    config.lograge.enabled = true

#    config.lograge.custom_options = lambda do |event|
#    #        params = event.payload[:params].reject { |k| %w(controller action).include?(k) }
#    #        { "params" => params }
#    #    end
  end
end
