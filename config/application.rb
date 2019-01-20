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

    config.active_record.schema_format = :sql

    config.autoload_paths << "#{Rails.root}/lib"
    config.autoload_paths << "#{Rails.root}/app/services"
    config.autoload_paths << "#{Rails.root}/app/plugins"

    config.elicit = config_for(:elicit_config)

    config.time_series_schema = config_for(:time_series_schema_config)

    log_level = String(ENV['LOG_LEVEL'] || "info").upcase
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    logger.level = Logger.const_get(log_level)
    config.logger = ActiveSupport::TaggedLogging.new(logger)

    config.log_level = log_level
    config.lograge.enabled = true

#    config.lograge.custom_options = lambda do |event|
#    #        params = event.payload[:params].reject { |k| %w(controller action).include?(k) }
#    #        { "params" => params }
#    #    end
  end
end
