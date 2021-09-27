# frozen_string_literal: true

module Authenticatable
  def current_api_user
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token&.resource_owner_id
  end

  def current_api_user_id
    doorkeeper_token&.resource_owner_id
  end

  def current_user
    @current_user ||= if doorkeeper_token
                        User.find(doorkeeper_token.resource_owner_id)
                      else
                        warden.authenticate(scope: :user, store: false)
                      end
  end

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", force: true)
    self.resource = send(:"current_#{resource_name}")
  end

  def authenticate_user!(force: false)
    raise 'unauthorized' if doorkeeper_token.blank?
  end
end
