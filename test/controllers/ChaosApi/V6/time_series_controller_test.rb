require_relative '../../../test_helper'
require 'minitest/unit'
require 'mocha/minitest'
require 'minitest/mock'
require 'fakefs/safe'

module ChaosApi
  module V6
    class TimeSeriesControllerTest < ActionDispatch::IntegrationTest
      test 'face_landmark json single row' do
        as_user(user(:registered_user)) do |headers|

          @study_definition = study_definition(:learning_study)
          @protocol_definition = protocol_definition(:learning_study)

          @phase_definition = phase_definition(:learning_study)

          @trial_definition = trial_definition(:learning_study_1)
          @user = user(:registered_user)

          @stage = study_result_stage(:learning_study_1)

          session_params = {
            user_id: @user.id,
            session_guid: SecureRandom.uuid,
            url: 'foo',
            expires_at: Date.today + 1.day,
            study_definition_id: @study_definition.id,
            protocol_definition_id: @protocol_definition.id,
            protocol_user_id: nil,
            phase_definition_id: @phase_definition.id,
            trial_definition_id: @trial_definition.id,
            stage_id: @stage.id,
            preview: false
          }

          @chaos_session = Chaos::ChaosSession.new(session_params)
          @chaos_session.save!

          post chaos_api_v6_time_series_url, params: { sessionGUID: @chaos_session.session_guid, seriesType: 'face_landmark', data: [{ test: 'this' }]}, as: :json, headers: headers
          assert_response :success

          time_series = StudyResult::TimeSeries.last
          assert time_series.present?
          # TODO: check path format?
          assert File.read(time_series.file.path) == { test: 'this' }.to_json
        end
      end

    end
  end
end
