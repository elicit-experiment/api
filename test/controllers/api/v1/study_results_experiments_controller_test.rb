# frozen_string_literal: true

require 'test_helper'
require 'minitest/unit'
require 'mocha/minitest'
require 'minitest/mock'

module Api::V1
  module StudyResults
    class ExperimentsControllerTest < ActionDispatch::IntegrationTest
      test 'should get index' do
        @study_result = study_result_study_result(:investigator_study_result1)
        @experiment = study_result_experiment(:investigator_study_result1)
        as_user(user(:admin)) do |headers|
          get api_v1_study_result_experiments_url(study_result_id: @study_result.id), as: :json, headers: headers
          assert_response :success
          json_response = JSON.parse(response.body)
          assert_equal 1, json_response.size, 'Did not get the experiment'
        end
      end

      test 'should show study result for study creator' do
        @study_result = study_result_study_result(:investigator_study_result1)
        @experiment = study_result_experiment(:investigator_study_result1)
        as_user(user(:investigator)) do |headers|
          get api_v1_study_result_experiment_url(study_result_id: @study_result.id, id: @experiment.id), as: :json, headers: headers
          assert_response :success
          json_response = JSON.parse(response.body)
          assert_equal @experiment.id, json_response['id'], 'Wrong experiment'
        end
      end

      test 'should show study result for admin' do
        @study_result = study_result_study_result(:investigator_study_result1)
        @experiment = study_result_experiment(:investigator_study_result1)
        as_user(user(:admin)) do |headers|
          get api_v1_study_result_experiment_url(study_result_id: @study_result.id, id: @experiment.id), as: :json, headers: headers
          assert_response :success
          json_response = JSON.parse(response.body)
          assert_equal @experiment.id, json_response['id'], 'Wrong experiment'
        end
      end

      test 'should not show study result for investigator who did not create study' do
        @study_result = study_result_study_result(:investigator_study_result1)
        @experiment = study_result_experiment(:investigator_study_result1)
        as_user(user(:investigator2)) do |headers|
          get api_v1_study_result_experiment_url(study_result_id: @study_result.id, id: @experiment.id), as: :json, headers: headers
          assert_response :forbidden
        end
      end
    end
  end
end
