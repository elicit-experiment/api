#Rails.application.config.middleware.insert_before 0, Rack::Cors, :debug => true, :logger => (-> { Rails.logger }) do
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  pfe = Rails.configuration.elicit['participant_frontend']
  uri = URI("#{pfe['scheme']}://#{pfe['host']}:#{pfe['port']}")
  puts "CORS allow origin #{uri.to_s}"
  allow do
     origins uri.to_s, 'https://elicit-experiment.docker.local'
     resource '*',
      headers: :any,
      expose: %w[Origin X-Requested-With Content-Type Accept Authorization],
      methods: %i(get post put patch delete options head),
      credentials: true
  end
end
