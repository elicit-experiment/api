# frozen_string_literal: true

require_relative 'boot'
require "rails"
require "active_storage/engine"
%w(
  active_record/railtie
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  rails/test_unit/railtie
  sprockets/railtie
  dotenv_rails
).each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end

require './lib/elicit_log_formatter'
require './lib/handle_compressed_requests'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ElicitApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.api_only = false

    config.active_record.schema_format = :ruby

    config.autoload_paths << "#{Rails.root}/lib"
    config.autoload_paths << "#{Rails.root}/app/services"
    config.autoload_paths << "#{Rails.root}/app/plugins"

    config.elicit = config_for(:elicit_config)

    config.time_series_schema = config_for(:time_series_schema_config)

    config.dotenv.overwrite = false
    Dotenv::Rails.overwrite = false
    puts "Loading .env file"
    ActiveSupport::Notifications.subscribe("load.dotenv") do |*args|
      puts args
    end

    elicit_portal = Rails.configuration.elicit['elicit_portal'].symbolize_keys
    port = elicit_portal[:port]
    port = nil if elicit_portal[:scheme] == 'https' && port == 443
    port = nil if elicit_portal[:scheme] == 'http' && port == 80
    default_url_options_config = {
      protocol: elicit_portal[:scheme],
      host: elicit_portal[:host]
    }
    default_url_options_config[:port] = port if port
    Rails.application.routes.default_url_options = default_url_options_config

    config.middleware.insert_before 0, HandleCompressedRequests

    config.environment = {
      public_facing?: (elicit_portal[:host].include?('compute.dtu.dk') || false)
      #        external_host: "#{elicit_portal[:host]}",
      #        external_hostname: "#{elicit_portal[:scheme]}://#{elicit_portal[:host] + port}",
      #        external_protocol: elicit_portal[:scheme]
    }

    base_logger = ActiveSupport::Logger.new(STDOUT)
    logger = if ENV.fetch('LOG_AS_JSON', Rails.env.production? ? 'true' : 'false') == 'true'
               # Formatter to log JSON in a similar fashion to lograge with logstash.
               config.log_formatter = ElicitLogFormatter.new
               base_logger.tap { |logger| logger.formatter = config.log_formatter }
             else
               ActiveSupport::TaggedLogging.new(base_logger)
             end

    config.logger        = logger
  end
end
