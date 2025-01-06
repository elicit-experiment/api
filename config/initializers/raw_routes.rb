# app/middleware/clear_action_dispatch_params.rb

# Avoid middleware parsing the parameters of these raw payloads by fixing the parameters and content type explicitly.
class FixActionDispatchParams
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'].to_s.end_with?('raw')
      if env['PATH_INFO'].match?(/time_series\/(\w+)\/file_raw/)
        env['action_dispatch.request.parameters'] = {series_type: $1, :format => :ndjson}
        env['action_dispatch.request.formats'] = [Mime::Type.lookup_by_extension(:ndjson)]
        env['action_dispatch.request.content_type'] = Mime::Type.lookup_by_extension(:ndjson)
      else
        env['action_dispatch.request.parameters'] = {}
      end
    end
    @app.call(env)
  end
end

#Rails.application.config.middleware.insert_before Rails::Rack::Logger, FixActionDispatchParams
