# frozen_string_literal: true

# Rails.application.config.middleware.insert_before 0, Rack::Cors, :debug => true, :logger => (-> { Rails.logger }) do
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  pfe = Rails.configuration.elicit['participant_frontend']
  puts Rails.configuration.elicit
  puts ENV['API_SCHEME']
  puts ENV['SITE_SUFFIX']
  uri = URI("#{pfe['scheme']}://#{pfe['host']}:#{pfe['port']}")
  puts "CORS allow origin #{uri}"
  allow do
    origins uri.to_s, 'https://elicit-experiment.docker.local'
    resource '*',
             headers: :any,
             expose: %w[Origin X-Requested-With Content-Type Accept Authorization],
             methods: %i[get post put patch delete options head],
             credentials: true
  end
end
