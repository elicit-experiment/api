# frozen_string_literal: true

require 'test_helper'
require 'minitest/unit'
require 'mocha/minitest'
require 'minitest/mock'

module Api::V1
  module StudyResults
    class StudyResultsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @study_result = study_result_study_result(:one)
      end

      test 'should get index' do
        as_user(user(:admin)) do |headers|
          get api_v1_study_results_url, as: :json, headers: headers
          assert_response :success
          json_response = JSON.parse(response.body)
          assert_equal 4, json_response.size, 'Did not get the study result'
        end
      end

      test 'should show study result' do
        as_user(user(:admin)) do |headers|
          get api_v1_study_result_url(id: @study_result.id), as: :json, headers: headers
          assert_response :success
          json_response = JSON.parse(response.body)
          assert_equal @study_result.id, json_response['id'], 'Wrong study result'
        end
      end

      test 'should not show study result for investigator who did not create study' do
        as_user(user(:investigator)) do |headers|
          get api_v1_study_result_url(id: @study_result.id), as: :json, headers: headers
          assert_response :forbidden
        end
      end

      test 'should not show study result for investigator who did not create study created by other investigator' do
        @study_result = study_result_study_result(:investigator_study_result1)
        as_user(user(:investigator2)) do |headers|
          get api_v1_study_result_url(id: @study_result.id), as: :json, headers: headers
          assert_response :forbidden
        end
      end

      test 'should show study result for investigator who created the study' do
        @study_result = study_result_study_result(:investigator_study_result1)
        as_user(user(:investigator)) do |headers|
          get api_v1_study_result_url(id: @study_result.id), as: :json, headers: headers
          assert_response :ok
        end
      end
    end
  end
end
