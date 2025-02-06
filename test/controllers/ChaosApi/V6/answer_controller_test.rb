require_relative '../../../test_helper'
require 'minitest/unit'
require 'mocha/minitest'
require 'minitest/mock'
require 'fakefs/safe'

module ChaosApi
  module V6
    class AnswerControllerTest < ActionDispatch::IntegrationTest
      def initialize_study_result
        @study_definition = study_definition(:learning_study)
        @protocol_definition = protocol_definition(:learning_study)

        @phase_definition = phase_definition(:learning_study)
        @protocol_user = protocol_user(:learning_study_1)
        @trial_definition = trial_definition(:learning_study_1)
        @component = component(:learning_study_1)
        @user = user(:registered_user)

        @stage = study_result_stage(:learning_study_1)

        session_params = {
          user_id: @user.id,
          session_guid: SecureRandom.uuid,
          url: 'foo',
          expires_at: Date.today + 1.day,
          study_definition_id: @study_definition.id,
          protocol_definition_id: @protocol_definition.id,
          protocol_user_id: @protocol_user.id,
          phase_definition_id: @phase_definition.id,
          trial_definition_id: @trial_definition.id,
          stage_id: @stage.id,
          preview: false
        }

        @chaos_session = Chaos::ChaosSession.new(session_params)
        @chaos_session.save!
      end

      test 'no session' do
        as_user(user(:registered_user)) do |headers|
          initialize_study_result

          params = {
            questionId: "#{@study_definition.id}::#{@component.id}",
            sessionGUID: 'does not exist',
            format: 'json2',
            user_http_status_codes: 'false'
          }

          # First post will create the state.
          post chaos_api_v6_answer_create_url, params: params, headers: headers
          assert_response :unprocessable_entity
        end
      end

      test 'invalid parameter format' do
        as_user(user(:registered_user)) do |headers|
          initialize_study_result

          params = {
            questionId: "#{@study_definition.id}:",
            sessionGUID: @chaos_session.session_guid,
            format: 'json2',
            user_http_status_codes: 'false'
          }

          # First post will create the state.
          post chaos_api_v6_answer_create_url, params: params, headers: headers
          assert_response :unprocessable_entity
        end
      end

      test 'non-existent parameters' do
        as_user(user(:registered_user)) do |headers|
          initialize_study_result

          params = {
            questionId: "#{@study_definition.id}:#{Component.last.id + 1}",
            sessionGUID: @chaos_session.session_guid,
            format: 'json2',
            user_http_status_codes: 'false'
          }

          # First post will create the state.
          post chaos_api_v6_answer_create_url, params: params, headers: headers
          assert_response :not_found
        end
      end

      test 'update the state' do
        as_user(user(:registered_user)) do |headers|

          initialize_study_result

          params = {
            questionId: "#{@study_definition.id}:#{@component.id}",
            output: '{"Text":"f","Events":[{"Id":"Freetext","Type":"Render","EntityType":"Instrument","Method":"","Data":"{\"Text\":\"Please write what you think about this excerpts\"}","DateTime":"2024-10-28T19:17:12.227Z"},{"Id":"Freetext","Type":"Change","EntityType":"Instrument","Method":"Keyboard","Data":"f","DateTime":"2024-10-28T19:17:20.372Z"}]}',
            sessionGUID: @chaos_session.session_guid,
            format: 'json2',
            user_http_status_codes: 'false'
          }

          # First post will create the state.
          post chaos_api_v6_answer_create_url, params: params, headers: headers
          assert_response :success

          json_response = JSON.parse(response.body)

          data_point_ids = json_response.dig('Body', 'Results', 'ids').map(&:to_i)
          data_points = data_point_ids.map { |id| StudyResult::DataPoint.find(id) }
          data_points.each do |data_point|
            assert_equal data_point.entity_type, 'Instrument'
            assert_equal data_point.kind, 'Freetext'
          end
          assert_equal data_points.last.point_type, 'State'
          assert_equal data_points.last.value, '{"Text":"f"}'
          assert_equal data_points.size, 3
          first_post_ids = data_points.map(&:id)

          params[:output] = '{"Text":"ff","Events":[{"Id":"Freetext","Type":"Render","EntityType":"Instrument","Method":"","Data":"{\"Text\":\"Please write what you think about this excerpts\"}","DateTime":"2024-10-28T19:17:12.227Z"},{"Id":"Freetext","Type":"Change","EntityType":"Instrument","Method":"Keyboard","Data":"f","DateTime":"2024-10-28T19:17:20.372Z"},{"Id":"Freetext","Type":"Change","EntityType":"Instrument","Method":"Keyboard","Data":"ff","DateTime":"2024-10-28T19:55:01.808Z"}]}
'
          post chaos_api_v6_answer_create_url, params: params, headers: headers
          assert_response :success

          json_response = JSON.parse(response.body)
          data_point_ids = json_response.dig('Body', 'Results', 'ids').map(&:to_i)
          data_points = data_point_ids.map { |id| StudyResult::DataPoint.find(id) }
          assert_equal 4, data_points.size
          assert_equal 'State', data_points.last.point_type
          assert_equal '{"Text":"ff"}', data_points.last.value

          # Only the state us updated; all the other events are deleted and recreated.
          common_ids = Set.new(data_points.map(&:id)) & Set.new(first_post_ids)
          assert_equal common_ids, Set.new([first_post_ids.last])
        end
      end
    end

    class AnswerControllerMultipleTest < ActionDispatch::IntegrationTest
      def initialize_study_result
        @chaos_session = chaos_chaos_session(:chaos_session_learning_study_1)
      end

      def run_trace(component, trace_name)
        datapoint_ids = Set.new([])
        as_user(user(:registered_user)) do |headers|
          @chaos_session = chaos_chaos_session(:chaos_session_learning_study_1)
          state_data_point_id = nil
          File.readlines(Rails.root.join("test/fixtures/files/api_traces/#{trace_name}.ndjson")).each do |line|
            params = JSON.parse(line)['params'].slice(*%w[questionId output sessionGUID format user_http_status_codes])
            params['sessionGUID'] = @chaos_session.session_guid
            params['questionId'] = "#{@chaos_session.study_definition_id}:#{component.id}"

            # First post will create the state.
            post chaos_api_v6_answer_create_url, params: params.symbolize_keys, headers: headers
            results = JSON.parse(response.body)['Body']['Results']['ids'] # changed data point ids
            datapoint_ids |= Set.new(results)
            assert_response :success

            states = StudyResult::DataPoint.where(stage_id: @chaos_session.stage_id, point_type: 'State')
            assert_equal 1, states.size
            state_data_point_id ||= states.first.id
            assert_equal state_data_point_id, states.first.id
          end
        end
        datapoint_ids
      end

      # %w[free_text].each do |trace_name|
      #   define_method "test_#{trace_name}" do
      #     component = component(:learning_study_1)
      #     trace_name = 'free_text'
      #
      #     datapoint_ids = run_trace(component, trace_name)
      #
      #     data_points = StudyResult::DataPoint.where(stage_id: @chaos_session.stage_id, id: datapoint_ids)
      #     data_points.each { |datapoint| Rails.logger.debug datapoint }
      #     assert_equal 4, data_points.size
      #
      #     assert_equal data_points.where(point_type: 'State').first.value, '{"Text":"1111"}'
      #     assert_equal 1, data_points.where(point_type: 'Render').size
      #     assert_equal 2, data_points.where(point_type: 'Change').size
      #   end
      # end
      test 'trace free_text' do
        component = component(:learning_study_1)
        trace_name = 'free_text'

        datapoint_ids = run_trace(component, trace_name)

        data_points = StudyResult::DataPoint.where(stage_id: @chaos_session.stage_id, id: datapoint_ids)
        data_points.each { |datapoint| Rails.logger.debug datapoint }
        assert_equal 170, data_points.size # 4 non-duplicates

        assert_equal data_points.where(point_type: 'State').first.value, '{"Text":"1111"}'
        assert_equal 36, data_points.where(point_type: 'Render').size
        assert_equal 133, data_points.where(point_type: 'Change').size
      end

      test 'trace radiobutton' do
        component = component(:learning_study_1)
        trace_name = 'radiobutton'

        datapoint_ids = run_trace(component, trace_name)

        data_points = StudyResult::DataPoint.where(stage_id: @chaos_session.stage_id, id: datapoint_ids)
        data_points.each { |datapoint| Rails.logger.debug datapoint }
        assert_equal 81, data_points.size

        assert_equal data_points.where(point_type: 'State').first.value, '{"Id":"4","Correct":true}'
        assert_equal 14, data_points.where(point_type: 'Render').size
        assert_equal 37, data_points.where(point_type: 'Change').size
      end
    end
  end
end
