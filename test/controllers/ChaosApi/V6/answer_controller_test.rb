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
          data_point_ids = json_response.dig('Body', 'Results').map(&:to_i)
          data_points = data_point_ids.map { |id| StudyResult::DataPoint.find(id) }
          data_points.each do |data_point|
            assert_equal data_point.entity_type, 'Instrument'
            assert_equal data_point.kind, 'Freetext'
          end
          assert_equal data_points.first.point_type, 'State'
          assert_equal data_points.first.value, '{"Text":"f"}'
          assert_equal data_points.size, 3
          first_post_ids = Set.new(data_points.map(&:id))

          params[:output] = '{"Text":"ff","Events":[{"Id":"Freetext","Type":"Render","EntityType":"Instrument","Method":"","Data":"{\"Text\":\"Please write what you think about this excerpts\"}","DateTime":"2024-10-28T19:17:12.227Z"},{"Id":"Freetext","Type":"Change","EntityType":"Instrument","Method":"Keyboard","Data":"f","DateTime":"2024-10-28T19:17:20.372Z"},{"Id":"Freetext","Type":"Change","EntityType":"Instrument","Method":"Keyboard","Data":"ff","DateTime":"2024-10-28T19:55:01.808Z"}]}
'
          post chaos_api_v6_answer_create_url, params: params, headers: headers
          assert_response :success

          json_response = JSON.parse(response.body)
          data_point_ids = json_response.dig('Body', 'Results').map(&:to_i)
          data_points = data_point_ids.map { |id| StudyResult::DataPoint.find(id) }
          assert_equal data_points.size, 4
          assert_equal data_points.first.point_type, 'State'
          assert_equal data_points.first.value, '{"Text":"ff"}'

          # Only the state us updated; all the other events are deleted and recreated.
          common_ids = Set.new(data_points.map(&:id)) & first_post_ids
          assert_equal common_ids, Set.new([first_post_ids.first])
        end
      end
    end
  end
end
