# frozen_string_literal: true

require 'test_helper'
require 'minitest/unit'
require 'mocha/mini_test'
require 'minitest/mock'

class StubToken
  def acceptable?(*_scopes)
    puts 'testing stub'
    true
  end
end

module Api::V1
  class UsersControllerTest < ActionDispatch::IntegrationTest
    test 'admin can upgrade user' do
      as_user(user(:admin)) do |headers|
        target_user = user(:registered_user)
        patch users_url(target_user), params: { user: { role: 'admin' } }, as: :json, headers: headers
        assert_response :success, 'investigator was not able to upgrade user to investigator'
      end
    end

    test 'investigator cannot upgrade user' do
      as_user(user(:investigator)) do |headers|
        target_user = user(:registered_user)
        patch users_url(target_user), params: { user: { role: 'admin' } }, as: :json, headers: headers
        assert_response :forbidden, 'investigator was able to upgrade user to investigator'
      end
    end

    test 'admin can create any kind of user' do
      %i[investigator admin registered_user].each do |role|
        as_user(user(:admin)) do |headers|
          post users_url, params: { user: { email: "new-#{role}@elicit.com", anonymous: false, role: role.to_s, password: 'abcd12_', password_confirmation: 'abcd12_' } }, as: :json, headers: headers
          assert_response :created, "Admin failed to create #{role}"
        end
      end
    end

    test 'investigator cannot create admin or other investigator' do
      %i[investigator admin].each do |role|
        as_user(user(:investigator)) do |headers|
          post users_url, params: { user: { email: 'admin2@elicit.com', anonymous: false, role: role.to_s, password: 'abcd12_', password_confirmation: 'abcd12_' } }, as: :json, headers: headers
          assert_response :forbidden, "Failed to disallow create of #{role} by investigator"
        end
      end
    end

    test 'investigator or admin can create registered user' do
      %i[investigator admin].each do |role|
        as_user(user(role)) do |headers|
          post users_url, params: { user: { email: "newby#{role}@elicit.com", anonymous: false, role: 'registered_user', password: 'abcd12_', password_confirmation: 'abcd12_' } }, as: :json, headers: headers
          assert_response :created, "#{role} failed to create registered user"
        end
      end
    end

    test 'registered user cannot create any user' do
      %i[investigator admin registered_user].each do |role|
        as_user(user(:registered_user)) do |headers|
          post users_url, params: { user: { email: 'noouser@elicit.com', anonymous: false, role: role.to_s, password: 'abcd12_', password_confirmation: 'abcd12_' } }, as: :json, headers: headers
          assert_response :forbidden
        end
      end
    end
  end
end
