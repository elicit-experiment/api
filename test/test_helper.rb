# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'dotenv'
Dotenv.load('.env.test.local')

require_relative '../config/environment'
require 'rails/test_help'

require 'minitest/autorun'
require 'rails/test_help'
require 'mocha/minitest'
#require 'fakefs'

class StubToken
  def acceptable?(*_scopes)
    puts 'testing stub'
    true
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def as_user(user)
    @user = user
    @dk_app = oauth_applications(:test_app)
    @token = Doorkeeper::AccessToken.new(application_id: @dk_app.id, resource_owner_id: @user.id, expires_in: 2.hours, scopes: :public, created_at: 2.seconds.ago)
    @token.save!
    @headers = { Authorization: "Bearer #{@token.token}" }
    yield @headers
  end
end

Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.service.root)
end