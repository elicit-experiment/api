# frozen_string_literal: true

if false && (Rails.env.development? || !Rails.configuration.environment[:public_facing?])
  require 'rack-mini-profiler'

  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)
end
