# frozen_string_literal: true

require 'test_helper'

module ChaosApi
  module V6
    class QuestionControllerTest < ActionDispatch::IntegrationTest
      test 'back navigation restores only the current participant answer and event history' do
        session = chaos_chaos_session(:chaos_session_learning_study_1)
        component = component(:learning_study_1)
        session.update!(user_id: session.protocol_user.user_id)
        TrialOrder.where(phase_definition_id: session.phase_definition_id).update_all(sequence_data: component.trial_definition_id.to_s)
        origin = {
          stage_id: session.stage_id, protocol_user_id: session.protocol_user_id,
          phase_definition_id: session.phase_definition_id,
          trial_definition_id: component.trial_definition_id, component_id: component.id
        }
        StudyResult::DataPoint.create!(**origin, point_type: 'State', value: '{"Text":"saved answer"}')
        StudyResult::DataPoint.create!(**origin, point_type: 'Change', kind: 'Freetext', entity_type: 'Instrument',
                                      method: 'Keyboard', value: 'saved answer', datetime: Time.current)
        StudyResult::DataPoint.create!(**origin.merge(protocol_user_id: protocol_user(:learning_study_2).id),
                                      point_type: 'State', value: '{"Text":"someone else"}')

        get '/v6/Question/Get', params: { id: session.protocol_definition_id, index: 0, sessionGUID: session.session_guid },
                                headers: { 'Accept' => 'application/json' }
        assert_response :success
        output = JSON.parse(response.body).fetch('Body').fetch('Results').first.fetch('Output')
        assert_equal 'saved answer', output.fetch('Text')
        event = output.fetch('Events').first
        assert_equal 'Freetext', event.fetch('Id')
        assert_equal 'Instrument', event.fetch('EntityType')
        assert_equal 'saved answer', event.fetch('Data')
        assert_equal 1, output.fetch('Events').size
      end
    end
  end
end
