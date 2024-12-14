# frozen_string_literal: true

class ApplicationController < ActionController::API
  include PreloadHeaders

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #  protect_from_forgery with: :exception
  #  protect_from_forgery with: :null_session

  # before_action :cors_preflight_check
  # after_action :cors_set_access_control_headers

  # For all responses in this controller, return the CORS access control headers.

  # TODO: make this less open when we actually go to deploy
  def cors_set_access_control_headers
    pfe = Rails.configuration.elicit[:participant_frontend]
    url = "#{pfe[:host]}:#{pfe[:port]}"

    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    headers['Access-Control-Max-Age'] = '1728000'
  end

  def cors_preflight_check
    Rails.logger.info 'preflight'
    if request.method == :options
      pfe = Rails.configuration.elicit[:participant_frontend]
      url = "#{pfe[:host]}:#{pfe[:port]}"

      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
      headers['Access-Control-Max-Age'] = '1728000'
      render text: 'opop', content_type: 'text/plain'
      head :ok
    end
  end

  def not_found
    head :not_found
  end
end
