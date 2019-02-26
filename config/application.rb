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

    elicit_portal = Rails.configuration.elicit['elicit_portal'].symbolize_keys
    port = elicit_portal[:port]
    port = nil if elicit_portal[:scheme] == 'https' && port == 443
    port = nil if elicit_portal[:scheme] == 'http' && port == 80
    default_url_options_config = {
        :protocol => elicit_portal[:scheme],
        :host => elicit_portal[:host]
    }
    default_url_options_config[:port] = port if port
    Rails.application.routes.default_url_options = default_url_options_config

    config.environment = {
        public_facing?: (elicit_portal[:host].include?('compute.dtu.dk') || false)
#        external_host: "#{elicit_portal[:host]}",
#        external_hostname: "#{elicit_portal[:scheme]}://#{elicit_portal[:host] + port}",
#        external_protocol: elicit_portal[:scheme]
    }

    logger               = ActiveSupport::Logger.new(STDOUT)
    logger.formatter     = config.log_formatter
    config.logger        = ActiveSupport::TaggedLogging.new(logger)

    config.lograge.enabled = true
    unless Rails.env.production?
      # log rage doesn't log params by default.
      # For production, though, the params can be HUGE (e.g. webgazer datapoints, so let's be cautious)
      config.lograge.custom_options = lambda do |event|
        exceptions = %w[controller action format id points]
        { params: event.payload[:params].except(*exceptions) }
      end
    end
    if config.lograge.enabled
      class ActionDispatch::DebugExceptions
        alias old_log_error log_error

        def log_error(env, wrapper)
          exception = wrapper.exception
          if exception.is_a?(ActionController::RoutingError)
            data = {
                method: env['REQUEST_METHOD'],
                path: env['REQUEST_PATH'],
                status: wrapper.status_code,
                error: "#{exception.class.name}: #{exception.message}"
            }
            formatted_message = Lograge.formatter.call(data)
            logger(env).send(Lograge.log_level, formatted_message)
          else
            old_log_error env, wrapper
          end
        end
      end
    end

  end
end
