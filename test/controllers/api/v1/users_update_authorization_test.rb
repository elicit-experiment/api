# frozen_string_literal: true

require 'test_helper'
require 'minitest/unit'
require 'mocha/minitest'
require 'minitest/mock'

module Api
  module V1
    # Regression coverage for issue #40: every user update must be authorized
    # against the target account, including payloads without a role.
    class UsersUpdateAuthorizationTest < ActionDispatch::IntegrationTest
      test 'registered user cannot change another user email' do
        as_user(user(:registered_user)) do |headers|
          target_user = user(:subject1)
          original_email = target_user.reload.email

          patch user_url(target_user), params: { user: { email: 'hijacked@elicit.com' } }, as: :json, headers: headers

          assert_response :forbidden
          assert_equal original_email, target_user.reload.email
        end
      end

      test 'registered user cannot change another user password' do
        as_user(user(:registered_user)) do |headers|
          target_user = user(:subject1)
          original_password = target_user.reload.encrypted_password

          patch user_url(target_user),
                params: { user: { password: 'hijacked123', password_confirmation: 'hijacked123' } },
                as: :json, headers: headers

          assert_response :forbidden
          assert_equal original_password, target_user.reload.encrypted_password
        end
      end

      test 'investigator cannot change another user email or password' do
        as_user(user(:investigator)) do |headers|
          target_user = user(:registered_user)
          original_email = target_user.reload.email
          original_password = target_user.reload.encrypted_password

          patch user_url(target_user),
                params: { user: { email: 'hijacked@elicit.com', password: 'hijacked123',
                                  password_confirmation: 'hijacked123' } },
                as: :json, headers: headers

          assert_response :forbidden
          target_user.reload
          assert_equal original_email, target_user.email
          assert_equal original_password, target_user.encrypted_password
        end
      end

      test 'client-only token cannot update a user' do
        token = Doorkeeper::AccessToken.create!(application_id: oauth_applications(:test_app).id, scopes: 'public')
        headers = { Authorization: "Bearer #{token.token}" }
        target_user = user(:subject1)
        original_email = target_user.reload.email
        original_password = target_user.reload.encrypted_password

        patch user_url(target_user),
              params: { user: { email: 'hijacked@elicit.com', password: 'hijacked123',
                                password_confirmation: 'hijacked123' } },
              as: :json, headers: headers

        assert_response :forbidden
        target_user.reload
        assert_equal original_email, target_user.email
        assert_equal original_password, target_user.encrypted_password
      end

      test 'registered user can update own email and password' do
        as_user(user(:registered_user)) do |headers|
          me = user(:registered_user)

          patch user_url(me),
                params: { user: { email: 'updated@elicit.com', password: 'newpassword',
                                  password_confirmation: 'newpassword' } },
                as: :json, headers: headers

          assert_response :success
          me.reload
          assert_equal 'updated@elicit.com', me.email
          assert me.valid_password?('newpassword')
        end
      end

      test 'investigator can update own account' do
        as_user(user(:investigator)) do |headers|
          me = user(:investigator)

          patch user_url(me), params: { user: { email: 'investigator-updated@elicit.com' } }, as: :json, headers: headers

          assert_response :success
          assert_equal 'investigator-updated@elicit.com', me.reload.email
        end
      end

      test 'registered user cannot change own role' do
        as_user(user(:registered_user)) do |headers|
          me = user(:registered_user)

          patch user_url(me), params: { user: { role: 'admin' } }, as: :json, headers: headers

          assert_response :forbidden
          assert_equal 'registered_user', me.reload.role
        end
      end

      test 'registered user cannot change own auto-created flag' do
        as_user(user(:registered_user)) do |headers|
          me = user(:registered_user)

          patch user_url(me), params: { user: { auto_created: true } }, as: :json, headers: headers

          assert_response :forbidden
          assert_equal false, me.reload.auto_created
        end
      end

      test 'admin can update another user email, password and role' do
        as_user(user(:admin)) do |headers|
          target_user = user(:registered_user)

          patch user_url(target_user),
                params: { user: { email: 'admin-updated@elicit.com', password: 'newpassword',
                                  password_confirmation: 'newpassword', role: 'investigator' } },
                as: :json, headers: headers

          assert_response :success
          target_user.reload
          assert_equal 'admin-updated@elicit.com', target_user.email
          assert_equal 'investigator', target_user.role
          assert target_user.valid_password?('newpassword')
        end
      end
    end
  end
end
