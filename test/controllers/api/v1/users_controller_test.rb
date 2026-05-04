# frozen_string_literal: true

require 'test_helper'
require 'minitest/unit'
require 'mocha/minitest'
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
        patch user_url(target_user), params: { user: { id: target_user.id, role: 'admin' } }, as: :json, headers: headers
        assert_response :success, 'investigator was not able to upgrade user to investigator'
      end
    end

    test 'investigator cannot upgrade user' do
      as_user(user(:investigator)) do |headers|
        target_user = user(:registered_user)
        patch user_url(target_user), params: { user: { id: target_user.id, role: 'admin' } }, as: :json, headers: headers
        assert_response :forbidden, 'investigator was able to upgrade user to investigator'
      end
    end

    test 'admin can create any kind of user' do
      %i[investigator admin registered_user].each do |role|
        as_user(user(:admin)) do |headers|
          post users_url,
               params: { user: { email: "new-#{role}@elicit.com", anonymous: false, role: role.to_s, password: 'abcd12_', password_confirmation: 'abcd12_' } }, as: :json, headers: headers
          assert_response :created, "Admin failed to create #{role}"
        end
      end
    end

    test 'investigator cannot create admin or other investigator' do
      %i[investigator admin].each do |role|
        as_user(user(:investigator)) do |headers|
          post users_url,
               params: { user: { email: 'admin2@elicit.com', anonymous: false, role: role.to_s, password: 'abcd12_', password_confirmation: 'abcd12_' } }, as: :json, headers: headers
          assert_response :forbidden, "Failed to disallow create of #{role} by investigator"
        end
      end
    end

    test 'investigator or admin can create registered user' do
      %i[investigator admin].each do |role|
        as_user(user(role)) do |headers|
          post users_url,
               params: { user: { email: "newby#{role}@elicit.com", anonymous: false, role: 'registered_user', password: 'abcd12_', password_confirmation: 'abcd12_' } }, as: :json, headers: headers
          assert_response :created, "#{role} failed to create registered user"
        end
      end
    end

    test 'registered user cannot create any user' do
      %i[investigator admin registered_user].each do |role|
        as_user(user(:registered_user)) do |headers|
          post users_url,
               params: { user: { email: 'noouser@elicit.com', anonymous: false, role: role.to_s, password: 'abcd12_', password_confirmation: 'abcd12_' } }, as: :json, headers: headers
          assert_response :forbidden
        end
      end
    end

    test 'index returns paginated users with correct headers' do
      as_user(user(:admin)) do |headers|
        get users_url, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        assert body.is_a?(Array)
        assert_response_header_present 'Total'
        assert_response_header_present 'PageSize'
        assert_response_header_present 'TotalPages'
      end
    end

    test 'index excludes admin and investigator roles for non-admin user' do
      as_user(user(:investigator)) do |headers|
        get users_url, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        roles = body.map { |u| u['role'] }
        assert_not_includes roles, 'admin'
        assert_not_includes roles, 'investigator'
      end
    end

    test 'index includes all roles for admin user' do
      as_user(user(:admin)) do |headers|
        get users_url, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        roles = body.map { |u| u['role'] }
        assert_includes roles, 'admin'
        assert_includes roles, 'investigator'
      end
    end

    test 'index searches by username' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { q: 'subject1' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        assert_equal 1, body.size
        assert_equal 'subject1', body[0]['username']
      end
    end

    test 'index searches by email' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { q: 'subject2@elicit.com' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        assert_equal 1, body.size
        assert_equal 'subject2', body[0]['username']
      end
    end

    test 'index search is case-insensitive' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { q: 'SUBJECT1' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        assert_equal 1, body.size
        assert_equal 'subject1', body[0]['username']
      end
    end

    test 'index search escapes ILIKE wildcard characters' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { q: 'subject%' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        assert_equal 0, body.size
      end
    end

    test 'index search escapes underscore wildcard character' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { q: 'subject_' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        assert_equal 0, body.size
      end
    end

    test 'index search truncates long query strings' do
      as_user(user(:admin)) do |headers|
        long_query = 'a' * 200
        get users_url, params: { q: long_query }, headers: headers
        assert_response :success
      end
    end

    test 'index filters by role' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { role: 'registered_user' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        roles = body.map { |u| u['role'] }
        assert(roles.all? { |r| r == 'registered_user' })
      end
    end

    test 'index sorts by username ascending' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { sort_column: 'username', sort_direction: 'asc' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        usernames = body.map { |u| u['username'] }
        assert_equal usernames, usernames.sort
      end
    end

    test 'index sorts by username descending' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { sort_column: 'username', sort_direction: 'desc' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        usernames = body.map { |u| u['username'] }
        assert_equal usernames, usernames.sort.reverse
      end
    end

    test 'index sorts by email ascending' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { sort_column: 'email', sort_direction: 'asc' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        emails = body.map { |u| u['email'] }
        assert_equal emails, emails.sort
      end
    end

    test 'index sorts by role' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { sort_column: 'role', sort_direction: 'asc' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        roles = body.map { |u| u['role'] }
        assert_equal roles, roles.sort
      end
    end

    test 'index defaults to created_at descending sort' do
      as_user(user(:admin)) do |headers|
        get users_url, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        created_ats = body.map { |u| u['created_at'] }
        assert_equal created_ats, created_ats.sort.reverse
      end
    end

    test 'index ignores invalid sort column' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { sort_column: 'password' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        created_ats = body.map { |u| u['created_at'] }
        assert_equal created_ats, created_ats.sort.reverse
      end
    end

    test 'index combines search and sort' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { q: 'subject', sort_column: 'username', sort_direction: 'desc' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        usernames = body.map { |u| u['username'] }
        assert(usernames.all? { |u| u.include?('subject') })
        assert_equal usernames, usernames.sort.reverse
      end
    end

    test 'index combines role filter and sort' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { role: 'registered_user', sort_column: 'email', sort_direction: 'asc' }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        roles = body.map { |u| u['role'] }
        assert(roles.all? { |r| r == 'registered_user' })
        emails = body.map { |u| u['email'] }
        assert_equal emails, emails.sort
      end
    end

    test 'index paginates results' do
      as_user(user(:admin)) do |headers|
        get users_url, params: { page_size: 1 }, headers: headers
        assert_response :success
        body = JSON.parse(response.body)
        assert_equal 1, body.size
        assert_equal '1', response.headers['PageSize']
      end
    end

    private

    def assert_response_header_present(header_name)
      assert response.headers[header_name], "Expected response header '#{header_name}' to be present"
    end
  end
end
