require_relative '../../../test_helper'
require 'minitest/unit'
require 'mocha/minitest'
require 'minitest/mock'
require 'fakefs/safe'

module ChaosApi
  module V6
    class TimeSeriesControllerRawTest < ActionController::TestCase
      def setup
        super
        @controller = TimeSeriesRawController.new
      end

      def raw_post(action, params, body, **kwargs)
        @request.env['RAW_POST_DATA'] = body
        response = post(action, params, **kwargs)
        @request.env.delete('RAW_POST_DATA')
        response
      end

      def initialize_study_result
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

        StudyResult::TimeSeries.destroy_all
      end


      test 'without authorization' do
        initialize_study_result

        # Not sending the auth header!
        # headers['X-CHAOS-SESSION-GUID'] = @chaos_session.session_guid

        body = [{a:'b'}].to_json

        post :append, body: body,  params: { series_type: 'face_landmark'}, as: :json
        assert_response :unauthorized
      end

      test 'with invalid authorization' do
        initialize_study_result

        @request.headers['X-CHAOS-SESSION-GUID'] = SecureRandom.uuid

        body = [{a:'b'}].to_json

        post :append, body: body,  params: { series_type: 'face_landmark'}, as: :json
        assert_response :unauthorized
      end

      test 'face_landmark disallows tsv format' do
        as_user(user(:registered_user)) do |headers|
          initialize_study_result

          headers['X-CHAOS-SESSION-GUID'] = @chaos_session.session_guid
          headers['CONTENT-TYPE'] = 'text/tab-separated-values'
          headers.each { |k,v| @request.headers[k] = v }

          body = [{a:'b'}].to_json

          post :append, body: body,  params: { series_type: 'face_landmark'}
          assert_response :unsupported_media_type
        end
      end

      test 'face_landmark json single row' do
        as_user(user(:registered_user)) do |headers|

          initialize_study_result

          headers['X-CHAOS-SESSION-GUID'] = @chaos_session.session_guid
          headers['CONTENT-TYPE'] = 'application/json; charset=utf-8'

          headers.each do |k,v|
            @request.headers[k] = v
          end

          body = [{a:'b'}].to_json

          post :append, body: body,  params: { series_type: 'face_landmark' }, as: :json
          assert_response :success
          assert_equal([Mime::Type.lookup_by_extension(:json).to_s, 'charset=utf-8'].join('; '), response.headers['CONTENT-TYPE'])
          assert_equal(JSON.parse(response.body).dig('Body','Count'), 0)

          time_series = StudyResult::TimeSeries.where({
            stage_id: @chaos_session.stage_id,
            study_definition_id: @study_definition.id,
            protocol_definition_id: @chaos_session.protocol_definition_id,
            phase_definition_id: @phase_definition.id,
            schema: 'face_landmark_json',
            schema_metadata: nil
          })
          assert time_series.present?
          assert_equal time_series.size, 1
          assert_equal File.read(time_series.first.in_progress_file_path).strip, body
          time_series.destroy_all
        end
      end

      test 'reuses same time series' do
        as_user(user(:registered_user)) do |headers|
          initialize_study_result

          headers['X-CHAOS-SESSION-GUID'] = @chaos_session.session_guid
          headers.each do |k,v|
            @request.headers[k] = v
          end

          time_series = StudyResult::TimeSeries.where({
                                                        stage_id: @chaos_session.stage_id,
                                                        study_definition_id: @study_definition.id,
                                                        protocol_definition_id: @chaos_session.protocol_definition_id,
                                                        phase_definition_id: @phase_definition.id,
                                                        schema: 'face_landmark_json',
                                                        schema_metadata: nil
                                                      })
          assert time_series.blank?

          body = { test: 'this' }.to_json
          post :append, body: body,  params: { series_type: 'face_landmark'}, as: :json

          assert_response :success
          new_timeseries_ids = Set.new(StudyResult::TimeSeries.all.pluck(:id))
          assert_equal(new_timeseries_ids.size, 1)

          post :append, body: body,  params: { series_type: 'face_landmark'}, as: :json
          assert_response :success

          new_timeseries_ids = Set.new(StudyResult::TimeSeries.all.pluck(:id))
          assert_equal(new_timeseries_ids.size, 1)
          assert_equal [body, body].join(''), File.read(StudyResult::TimeSeries.find(new_timeseries_ids.first).in_progress_file_path).strip
        end
      end

    end
  end
end
