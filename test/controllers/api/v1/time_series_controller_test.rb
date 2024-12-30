# frozen_string_literal: true

require 'test_helper'
require 'minitest/unit'
require 'mocha/minitest'
require 'minitest/mock'

module Api
  module V1
    class TimeSeriesControllerTest < ActionDispatch::IntegrationTest
      test 'return 200' do
        as_user(user(:admin)) do |headers|
          series = study_result_time_series(:learning_time_series_1)
          study_result = study_result_study_result(:learning_study_1)
          get api_v1_study_result_time_series_url(id: series.id, study_result_id: study_result.id), params: {  }, as: :json, headers: headers
          assert_response :ok, 'Request failed'

          json_response = JSON.parse(response.body)
          # TODO: validate
          puts json_response
        end
      end

      test '#index return 200' do
        as_user(user(:admin)) do |headers|
          series = study_result_time_series(:learning_time_series_1)
          study_result = study_result_study_result(:learning_study_1)
          get api_v1_study_result_time_series_index_url(study_result_id: study_result.id), params: {  }, as: :json, headers: headers
          assert_response :ok, 'Request failed'

          json_response = JSON.parse(response.body)
          assert_equal json_response.size, 3, 'Response was not 3'
        end
      end

      test 'with new in progress urls' do
        as_user(user(:admin)) do |headers|
          series = study_result_time_series(:json_facelandmarker_time_series_2)
          study_result = study_result_study_result(:learning_study_2)
          get api_v1_study_result_time_series_url(id: series.id, study_result_id: study_result.id), params: {  }, as: :json, headers: headers
          assert_response :ok, 'Request failed'

          json_response = JSON.parse(response.body)
          # TODO: validate
          puts json_response
        end
      end

      test 'return 403 without authorization' do
        as_user(user(:admin)) do |headers|
          series = study_result_time_series(:learning_time_series_1)
          study_result = study_result_study_result(:learning_study_1)
          get api_v1_study_result_time_series_url(id: series.id, study_result_id: study_result.id), params: {  }, as: :json
          assert_response :unauthorized, 'Response was not unauthorized'
        end
      end
    end
  end
end

