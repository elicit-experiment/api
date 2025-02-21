# frozen_string_literal: true

return if Rails.env.development?

require 'lograge/sql/extension'

Rails.application.configure do #|config|
  config.lograge.logger = ActiveSupport::Logger.new(STDOUT)
  config.lograge.enabled = true
  config.lograge.base_controller_class = 'ActionController::API'
  config.lograge.formatter = Lograge::Formatters::Logstash.new

  unless Rails.env.production?
    # log rage doesn't log params by default.
    # For production, though, the params can be HUGE (e.g. webgazer datapoints, so let's be cautious)
    config.lograge.custom_options = lambda do |event|
      exceptions = %w[controller action format id points data]
      { params: event.payload[:params].except(*exceptions) }
    end
  end

  class ActionDispatch::DebugExceptions
    alias old_log_error log_error

    def log_error(env, wrapper)
      exception = wrapper.exception
      if exception.is_a?(ActionController::RoutingError)

        detail_fields = if env.respond_to?(:[])
                          {
                            method: env&.[]('REQUEST_METHOD'),
                            path: env&.[]('REQUEST_PATH')
                          }
                        else
                          {
                            klass: env.class.name,
                          }
                        end

        data = {
          status: wrapper.status_code,
          error: "#{exception.class.name}: #{exception.message}",
        }.merge(detail_fields)

        formatted_message = Lograge.formatter.call(data)
        logger(env).send(Lograge.log_level, formatted_message)
      else
        old_log_error env, wrapper
      end
    end
  end

  config.lograge_sql.keep_default_active_record_log = false

  # Instead of extracting event as Strings, extract as Hash. You can also extract
  # additional fields to add to the formatter
  config.lograge_sql.extract_event = Proc.new do |event|
    log_event = { name: event.payload[:name], duration: event.duration.to_f.round(2) }
    log_event[:sql] = event.payload[:sql] if ENV['LOG_SQL'] == 'true'
    log_event
  end

  # Format the array of extracted events
  config.lograge_sql.formatter = Proc.new do |sql_queries|
    sql_queries
  end
end
