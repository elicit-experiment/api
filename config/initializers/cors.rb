#Rails.application.config.middleware.insert_before 0, Rack::Cors, :debug => true, :logger => (-> { Rails.logger }) do
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  pfe = Rails.configuration.elicit['participant_frontend']
  url = "#{pfe['host']}:#{pfe['port']}"
  allow do
     origins url
     resource '*',
      headers: :any,
      expose: %w[Origin X-Requested-With Content-Type Accept Authorization],
      methods: %i(get post put patch delete options head),
      credentials: true
  end
end
