# frozen_string_literal: true

module ElicitErrors
  def not_found(message = 'object not found')
    raise ElicitError.new(message, :not_found)
  end

  def unprocessable_entity(message = 'invalid operation')
    raise ElicitError.new(message, :unprocessable_entity)
  end

  def permission_denied
    raise ElicitError.new('permission denied', :unauthorized)
  end

  def render_elicit_error(error)
    render json: error, status: error.code
    true
  end
end
