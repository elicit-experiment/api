require_relative '../../../test_helper'
require 'minitest/unit'
require 'mocha/minitest'
require 'minitest/mock'
require 'fakefs/safe'

module ChaosApi
  module V6
    class TimeSeriesControllerTest < ActionDispatch::IntegrationTest
      def initialize_study_result
        @study_definition = study_definition(:learning_study)
        @protocol_definition = protocol_definition(:learning_study)
        @phase_definition = phase_definition(:learning_study)
        @trial_definition = trial_definition(:learning_study_1)
        @user = user(:registered_user)
        @stage = study_result_stage(:learning_study_1)
        @trial_result = study_result_trial_result(:learning_study_1)

        session_params = {
          user_id: @user.id,
          session_guid: SecureRandom.uuid,
          url: 'foo',
          expires_at: Date.today + 1.day,
          study_definition_id: @study_definition.id,
          protocol_definition_id: @protocol_definition.id,
          protocol_user_id: @stage.protocol_user_id,
          phase_definition_id: @phase_definition.id,
          trial_definition_id: @trial_definition.id,
          trial_result_id: @trial_result.id,
          stage_id: @stage.id,
          preview: false
        }

        @chaos_session = Chaos::ChaosSession.new(session_params)
        @chaos_session.save!

        StudyResult::TimeSeries.destroy_all
      end

      test 'mouse tsv single row' do
        as_user(user(:registered_user)) do |headers|

          initialize_study_result

          file = fixture_file_upload('mouse_initial.tsv', 'text/tab-separated-values')

          post chaos_api_v6_time_series_file_url(series_type: :mouse), params: { sessionGUID: @chaos_session.session_guid, seriesType: 'mouse', file: file, series_type: 'mouse' }, headers: headers
          assert_response :success

          time_series = StudyResult::TimeSeries.where({
                                                        stage_id: @chaos_session.stage_id,
                                                        study_definition_id: @study_definition.id,
                                                        protocol_definition_id: @chaos_session.protocol_definition_id,
                                                        phase_definition_id: @phase_definition.id,
                                                        schema: 'mouse_tsv',
                                                        schema_metadata: nil
                                                      })
          assert time_series.present?
          assert_equal 1, time_series.size
          # TODO: check path format?
          assert_equal file.read, File.read(time_series.first.in_progress_file_path).strip
          time_series.destroy_all
        end
      end

      test 'reuses same time series' do
        as_user(user(:registered_user)) do |headers|
          initial_data_point_ids = Set.new(StudyResult::DataPoint.all.pluck(:id))
          initialize_study_result

          data_point = {
            datetime: Time.now.to_i,
            value: '',
            method: '',
            point_type: 'face_landmark_summary',
          }

          post chaos_api_v6_slide_datapoint_url, params: { sessionGUID: @chaos_session.session_guid, seriesType: 'face_landmark', content: data_point.to_json}, as: :json, headers: headers
          assert_response :success
          assert_equal(1, (Set.new(StudyResult::DataPoint.all.pluck(:id)) - initial_data_point_ids).size)

          post chaos_api_v6_slide_datapoint_url, params: { sessionGUID: @chaos_session.session_guid, seriesType: 'face_landmark', content: data_point.to_json}, as: :json, headers: headers
          assert_response :success
          assert_equal(2, (Set.new(StudyResult::DataPoint.all.pluck(:id)) - initial_data_point_ids).size)
        end
      end

    end
  end
end
