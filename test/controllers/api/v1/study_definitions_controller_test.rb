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
  class StudyDefinitionControllerTest < ActionDispatch::IntegrationTest
    #  include Devise::TestHelpers

    setup do
      @study_definition = study_definition(:one)
      @user = user(:admin)
      @dk_app = oauth_applications(:test_app)
      @token = Doorkeeper::AccessToken.new(application_id: @dk_app.id, resource_owner_id: @user.id, expires_in: 2.hours, scopes: :public, created_at: 2.seconds.ago)
      @token.save!
      # unecessary
      #    StudyDefinitionsController.any_instance.stubs(:doorkeeper_token).returns(@token)
      @headers = { Authorization: "Bearer #{@token.token}" }
    end

    test 'should get index' do
      get api_v1_study_definitions_url, as: :json, headers: @headers
      assert_response :success
    end

    test 'should create study_definition' do
      assert_difference('StudyDefinition.count') do
        post api_v1_study_definitions_url, params: { study_definition: { title: 'test post', principal_investigator_user_id: @user.id } }, as: :json, headers: @headers
      end

      assert_response :success
    end

    test 'investigator can create study_definition' do
      as_user(user(:investigator)) do |headers|
        assert_difference('StudyDefinition.count') do
          post api_v1_study_definitions_url, params: { study_definition: { title: 'test study' } }, as: :json, headers: headers
        end

        assert_response :success
      end
    end

    test 'investigator cannot create study_definition for another user' do
      as_user(user(:investigator)) do |headers|
        assert_no_difference('StudyDefinition.count') do
          params = { study_definition: { title: 'test study', principal_investigator_user_id: user(:admin).id } }
          post api_v1_study_definitions_url, params: params, as: :json, headers: headers
        end

        assert_response :unauthorized
      end
    end

    test 'registered_user cannot create study_definition' do
      as_user(user(:registered_user)) do |headers|
        assert_no_difference('StudyDefinition.count') do
          post api_v1_study_definitions_url, params: { study_definition: { title: 'test study' } }, as: :json, headers: headers
        end

        assert_response :forbidden
      end
    end

    test 'should show study_definition' do
      get api_v1_study_definition_url(@study_definition), as: :json, headers: @headers
      assert_response :success
    end

    test 'should update study_definition' do
      patch api_v1_study_definition_url(@study_definition), params: { study_definition: { title: 'new', principal_investigator_user_id: @user.id } }, as: :json, headers: @headers
      assert_response :success
    end

    test 'should destroy study_definition' do
      assert_difference('StudyDefinition.count', -1) do
        delete api_v1_study_definition_url(@study_definition), as: :json, headers: @headers
      end

      assert_response :success
    end

    test 'index returns studies ordered by created_at desc' do
      old_study = StudyDefinition.create!(title: 'Old Study', principal_investigator: user(:admin), created_at: 10.days.ago)
      new_study = StudyDefinition.create!(title: 'New Study', principal_investigator: user(:admin), created_at: 1.day.ago)

      get api_v1_study_definitions_url, as: :json, headers: @headers
      assert_response :success

      studies = JSON.parse(response.body)
      titles = studies.map { |s| s['title'] }
      assert titles.index('New Study') < titles.index('Old Study'), 'Expected new study to appear before old study'
    end

    test 'index paginates without overlap' do
      # Create enough studies to exceed default page size of 20
      25.times do |i|
        StudyDefinition.create!(title: "Paginated Study #{i}", principal_investigator: user(:admin), created_at: (i + 1).days.ago)
      end

      get api_v1_study_definitions_url, params: { page: 1, page_size: 10 }, as: :json, headers: @headers
      assert_response :success
      page1 = JSON.parse(response.body)
      assert_equal 10, page1.length

      get api_v1_study_definitions_url, params: { page: 2, page_size: 10 }, as: :json, headers: @headers
      assert_response :success
      page2 = JSON.parse(response.body)
      assert_equal 10, page2.length

      page1_ids = page1.map { |s| s['id'] }
      page2_ids = page2.map { |s| s['id'] }
      assert_empty page1_ids & page2_ids, 'Expected pages to not overlap'
    end

    test 'index does not duplicate studies with multiple protocols' do
      study = StudyDefinition.create!(title: 'Multi-Protocol Study', principal_investigator: user(:admin))
      ProtocolDefinition.create!(name: 'Protocol 1', study_definition: study, active: true)
      ProtocolDefinition.create!(name: 'Protocol 2', study_definition: study, active: true)

      get api_v1_study_definitions_url, as: :json, headers: @headers
      assert_response :success

      studies = JSON.parse(response.body)
      ids = studies.map { |s| s['id'] }
      assert_equal ids.uniq.length, ids.length, 'Expected no duplicate studies in index'
      assert_includes ids, study.id
    end
  end
end
