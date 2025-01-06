# frozen_string_literal: true

class ApplicationController < ActionController::API
  include PreloadHeaders

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  # protect_from_forgery with: :exception unless Rails.env.test?

  def not_found
    head :not_found
  end
end
