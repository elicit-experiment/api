# frozen_string_literal: true

require_relative '../../lib/elicit_config'

# Rails.application.config.middleware.insert_before 0, Rack::Cors, :debug => true, :logger => (-> { Rails.logger }) do
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ElicitConfig.participant_url.to_s, ElicitConfig.study_management_url.to_s

    resource '*',
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             credentials: true,
             max_age: 86400
  end
end
