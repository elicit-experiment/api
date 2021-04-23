# frozen_string_literal: true

# Rails.application.config.middleware.insert_before 0, Rack::Cors, :debug => true, :logger => (-> { Rails.logger }) do
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  pfe = Rails.configuration.elicit[:participant_frontend]
  if pfe[:scheme].present? && pfe[:host].present?
    uri = URI("#{pfe[:scheme]}://#{pfe[:host]}:#{pfe[:port]}")
    allow do
      origins uri.to_s, 'https://elicit-experiment.docker.local'
      resource '*',
               headers: :any,
               expose: %w[Origin X-Requested-With Content-Type Accept Authorization],
               methods: %i[get post put patch delete options head],
               credentials: true
    end
  end
end
