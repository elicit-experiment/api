# frozen_string_literal: true

module ElicitErrors
  extend ActiveSupport::Concern

  included do
    # The raw controller doesn't use respond_to, it handles the errors explicitly.
    rescue_from ElicitError, with: ->(error) { render_elicit_error(error) } if respond_to? :rescue_from
  end

  def not_found(message = 'object not found')
    raise ElicitError.new(message, :not_found)
  end

  def unprocessable_entity(message = 'invalid operation', details = nil)
    raise ElicitError.new(message, :unprocessable_entity, details)
  end

  def unsupported_media_type(message = 'unsupported media type', details = nil)
    raise ElicitError.new(message, :unsupported_media_type, details)
  end

  def permission_denied
    raise ElicitError.new('permission denied', :unauthorized)
  end

  def render_elicit_error(error)
    render json: error, status: error.code
    true
  end
end
