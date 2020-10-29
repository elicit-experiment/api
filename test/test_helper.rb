
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'minitest/autorun'
require 'rails/test_help'
require 'mocha/mini_test'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def as_user(user)
    @user = user
    @dk_app = oauth_applications(:test_app)
    @token = Doorkeeper::AccessToken.new(application_id: @dk_app.id, resource_owner_id: @user.id, expires_in: 2.hours, scopes: :public, created_at: 2.seconds.ago)
    @token.save!
    @headers = { :Authorization => "Bearer #{@token.token}"}
    yield @headers
  end
end
