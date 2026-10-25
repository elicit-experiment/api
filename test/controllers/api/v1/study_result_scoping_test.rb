# frozen_string_literal: true

require 'test_helper'
require 'minitest/unit'
require 'mocha/minitest'
require 'minitest/mock'

module Api
  module V1
    # Regression coverage for issue #41: research-result reads and mutations
    # must be scoped to the authorized parent study result.
    class StudyResultScopingTest < ActionDispatch::IntegrationTest
      setup do
        @learning_result = study_result_study_result(:learning_study_1)
        @other_result = study_result_study_result(:learning_study_2)
        @investigator_result = study_result_study_result(:investigator_study_result1)
        @other_series = study_result_time_series(:json_facelandmarker_time_series_2)
      end

      # --- top-level collection -------------------------------------------------

      test 'investigator index only returns results of studies they own' do
        as_user(user(:investigator)) do |headers|
          get api_v1_study_results_url, as: :json, headers: headers

          assert_response :success
          ids = JSON.parse(response.body).map { |result| result['id'] }
          assert_equal [@investigator_result.id], ids
        end
      end

      test 'investigator index is empty when they own no studies' do
        as_user(user(:investigator2)) do |headers|
          get api_v1_study_results_url, as: :json, headers: headers

          assert_response :success
          assert_equal [], JSON.parse(response.body)
        end
      end

      test 'registered user cannot list study results' do
        as_user(user(:registered_user)) do |headers|
          get api_v1_study_results_url, as: :json, headers: headers
          assert_response :forbidden
        end
      end

      test 'registered user cannot show a study result' do
        as_user(user(:registered_user)) do |headers|
          get api_v1_study_result_url(id: @learning_result.id), as: :json, headers: headers
          assert_response :forbidden
        end
      end

      test 'investigator cannot destroy a study result they do not own' do
        as_user(user(:investigator)) do |headers|
          delete api_v1_study_result_url(id: @learning_result.id), as: :json, headers: headers

          assert_response :forbidden
          assert StudyResult::StudyResult.exists?(@learning_result.id)
        end
      end

      test 'client-only token cannot list study results' do
        token = Doorkeeper::AccessToken.create!(application_id: oauth_applications(:test_app).id, scopes: 'public')
        get api_v1_study_results_url, as: :json, headers: { Authorization: "Bearer #{token.token}" }
        assert_response :forbidden
      end

      # --- nested collections ---------------------------------------------------

      test 'nested time series index only returns the parent study result series' do
        as_user(user(:admin)) do |headers|
          get api_v1_study_result_time_series_index_url(study_result_id: @learning_result.id), as: :json, headers: headers

          assert_response :success
          ids = JSON.parse(response.body).map { |series| series['id'] }
          assert_equal @learning_result.time_series.pluck(:id).sort, ids.sort
          assert_equal 3, ids.size
          assert_not_includes ids, @other_series.id
        end
      end

      test 'nested time series index ignores a stage filter from another study' do
        foreign_stage = study_result_stage(:learning_study_2)

        as_user(user(:admin)) do |headers|
          get api_v1_study_result_time_series_index_url(study_result_id: @learning_result.id),
              params: { stage_id: foreign_stage.id }, as: :json, headers: headers

          assert_response :success
          assert_equal [], JSON.parse(response.body)
        end
      end

      test 'nested experiment index only returns the parent study result experiments' do
        as_user(user(:admin)) do |headers|
          get api_v1_study_result_experiments_url(study_result_id: @learning_result.id), as: :json, headers: headers

          assert_response :success
          ids = JSON.parse(response.body).map { |experiment| experiment['id'] }
          assert_equal @learning_result.experiments.pluck(:id), ids
        end
      end

      test 'nested data points index is scoped to the parent study result' do
        foreign_stage = study_result_stage(:learning_study_2)

        as_user(user(:admin)) do |headers|
          get api_v1_study_result_data_points_url(study_result_id: @learning_result.id),
              params: { stage_id: foreign_stage.id }, as: :json, headers: headers

          assert_response :success
          assert_equal [], JSON.parse(response.body)
        end
      end

      test 'investigator cannot read another study result series collection' do
        as_user(user(:investigator)) do |headers|
          get api_v1_study_result_time_series_index_url(study_result_id: @learning_result.id), as: :json, headers: headers
          assert_response :forbidden
        end
      end

      test 'other investigator cannot read series collection of a study they do not own' do
        as_user(user(:investigator2)) do |headers|
          get api_v1_study_result_time_series_index_url(study_result_id: @investigator_result.id), as: :json, headers: headers
          assert_response :forbidden
        end
      end

      test 'investigator can read the series collection of their own study' do
        as_user(user(:investigator)) do |headers|
          get api_v1_study_result_time_series_index_url(study_result_id: @investigator_result.id), as: :json, headers: headers
          assert_response :success
          assert_equal [], JSON.parse(response.body)
        end
      end

      test 'registered user cannot read a nested result collection' do
        as_user(user(:registered_user)) do |headers|
          get api_v1_study_result_time_series_index_url(study_result_id: @learning_result.id), as: :json, headers: headers
          assert_response :forbidden
        end
      end

      # --- mismatched parent/child ids -----------------------------------------

      test 'show rejects a child that belongs to another study result' do
        as_user(user(:admin)) do |headers|
          get api_v1_study_result_time_series_url(study_result_id: @learning_result.id, id: @other_series.id),
              as: :json, headers: headers

          assert_response :not_found
        end
      end

      test 'experiment show rejects an experiment from another study result' do
        foreign_experiment = study_result_experiment(:investigator_study_result1)

        as_user(user(:admin)) do |headers|
          get api_v1_study_result_experiment_url(study_result_id: @learning_result.id, id: foreign_experiment.id),
              as: :json, headers: headers

          assert_response :not_found
        end
      end

      test 'destroy rejects a child that belongs to another study result' do
        foreign_experiment = study_result_experiment(:investigator_study_result1)

        as_user(user(:admin)) do |headers|
          delete api_v1_study_result_experiment_url(study_result_id: @learning_result.id, id: foreign_experiment.id),
                 as: :json, headers: headers

          assert_response :not_found
          assert StudyResult::Experiment.exists?(foreign_experiment.id)
        end
      end

      test 'time series content rejects a series from another study result' do
        as_user(user(:admin)) do |headers|
          get api_v1_study_result_time_series_content_url(study_result_id: @learning_result.id,
                                                          time_series_id: @other_series.id),
              as: :json, headers: headers

          assert_response :not_found
        end
      end

      # --- mutations ------------------------------------------------------------

      test 'admin can create an experiment under a study result' do
        as_user(user(:admin)) do |headers|
          post api_v1_study_result_experiments_url(study_result_id: @learning_result.id),
               params: { experiment: { protocol_user_id: protocol_user(:learning_study_1).id } },
               as: :json, headers: headers

          assert_response :created
          assert_equal @learning_result.id, JSON.parse(response.body)['study_result_id']
        end
      end

      test 'investigator cannot create a result under a study they do not own' do
        as_user(user(:investigator)) do |headers|
          post api_v1_study_result_experiments_url(study_result_id: @learning_result.id),
               params: { experiment: { protocol_user_id: protocol_user(:learning_study_1).id } },
               as: :json, headers: headers

          assert_response :forbidden
        end
      end

      test 'registered user cannot create a result' do
        as_user(user(:registered_user)) do |headers|
          post api_v1_study_result_experiments_url(study_result_id: @learning_result.id),
               params: { experiment: { protocol_user_id: protocol_user(:learning_study_1).id } },
               as: :json, headers: headers

          assert_response :forbidden
        end
      end

      test 'create time series rejects a stage from another study result' do
        foreign_stage = study_result_stage(:learning_study_2)

        as_user(user(:admin)) do |headers|
          assert_no_difference 'StudyResult::TimeSeries.count' do
            post api_v1_study_result_time_series_index_url(study_result_id: @learning_result.id),
                 params: { time_series: time_series_params(foreign_stage) }, as: :json, headers: headers
          end

          assert_response :forbidden
        end
      end

      test 'create time series accepts a stage from the parent study result' do
        as_user(user(:admin)) do |headers|
          assert_difference 'StudyResult::TimeSeries.count', 1 do
            post api_v1_study_result_time_series_index_url(study_result_id: @learning_result.id),
                 params: { time_series: time_series_params(study_result_stage(:learning_study_1)) },
                 as: :json, headers: headers
          end

          assert_response :created
        end
      end

      test 'update time series rejects re-parenting to another study result' do
        series = @learning_result.time_series.first
        foreign_stage = study_result_stage(:learning_study_2)

        as_user(user(:admin)) do |headers|
          patch api_v1_study_result_time_series_url(study_result_id: @learning_result.id, id: series.id),
                params: { time_series: { stage_id: foreign_stage.id } }, as: :json, headers: headers

          assert_response :forbidden
          assert_equal study_result_stage(:learning_study_1).id, series.reload.stage_id
        end
      end

      test 'update time series updates a child of the parent study result' do
        series = @learning_result.time_series.first

        as_user(user(:admin)) do |headers|
          patch api_v1_study_result_time_series_url(study_result_id: @learning_result.id, id: series.id),
                params: { time_series: { schema_metadata: 'updated' } }, as: :json, headers: headers

          assert_response :success
          assert_equal 'updated', series.reload.schema_metadata
        end
      end

      test 'destroy time series removes a child of the parent study result' do
        series = @learning_result.time_series.first

        as_user(user(:admin)) do |headers|
          delete api_v1_study_result_time_series_url(study_result_id: @learning_result.id, id: series.id),
                 as: :json, headers: headers

          assert_response :no_content
          assert_not StudyResult::TimeSeries.exists?(series.id)
        end
      end

      test 'investigator cannot destroy another study result child' do
        series = @learning_result.time_series.first

        as_user(user(:investigator)) do |headers|
          delete api_v1_study_result_time_series_url(study_result_id: @learning_result.id, id: series.id),
                 as: :json, headers: headers

          assert_response :forbidden
          assert StudyResult::TimeSeries.exists?(series.id)
        end
      end

      # --- top-level create -----------------------------------------------------

      test 'investigator can create a result for their own study' do
        study = study_definition(:investigator_study)

        as_user(user(:investigator)) do |headers|
          assert_difference 'StudyResult::StudyResult.count', 1 do
            post api_v1_study_results_url,
                 params: { study_result: { study_definition_id: study.id, user_id: user(:subject1).id } },
                 as: :json, headers: headers
          end

          assert_response :created
        end
      end

      test 'investigator cannot create a result for another study' do
        study = study_definition(:learning_study)

        as_user(user(:investigator)) do |headers|
          assert_no_difference 'StudyResult::StudyResult.count' do
            post api_v1_study_results_url,
                 params: { study_result: { study_definition_id: study.id, user_id: user(:subject1).id } },
                 as: :json, headers: headers
          end

          assert_response :forbidden
        end
      end

      test 'registered user cannot create a study result' do
        study = study_definition(:learning_study)

        as_user(user(:registered_user)) do |headers|
          post api_v1_study_results_url,
               params: { study_result: { study_definition_id: study.id, user_id: user(:subject1).id } },
               as: :json, headers: headers

          assert_response :forbidden
        end
      end

      # --- file urls ------------------------------------------------------------

      test 'responses never reveal another study result file urls' do
        series = study_result_time_series(:learning_mouse_time_series_1)
        series.append_raw("{\"x\":1}\n")
        series.save!
        leaked_url = series.reload.in_progress_file_url
        assert leaked_url.present?

        as_user(user(:admin)) do |headers|
          get api_v1_study_result_time_series_index_url(study_result_id: @other_result.id), as: :json, headers: headers
          assert_response :success
          assert_equal [@other_series.id], (JSON.parse(response.body).map { |s| s['id'] })
          assert_not_includes response.body, leaked_url

          get api_v1_study_result_time_series_url(study_result_id: @other_result.id, id: series.id),
              as: :json, headers: headers
          assert_response :not_found
          assert_not_includes response.body, leaked_url
        end
      end

      private

      def time_series_params(stage)
        {
          stage_id: stage.id,
          study_definition_id: stage.phase_definition.study_definition_id,
          protocol_definition_id: stage.phase_definition.protocol_definition_id,
          phase_definition_id: stage.phase_definition_id,
          schema: 'mouse_tsv'
        }
      end
    end
  end
end
