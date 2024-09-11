# frozen_string_literal: true

module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class DataPoint < ApplicationRecord
    belongs_to :protocol_user, class_name: 'ProtocolUser'
    belongs_to :phase_definition, class_name: 'PhaseDefinition'
    belongs_to :trial_definition, class_name: 'TrialDefinition'
    belongs_to :stage, class_name: 'Stage'
    belongs_to :component, class_name: 'Component', optional: true # We allow slides to be generated without components, and they can generate datapoints (e.g. calibration)
    belongs_to :context, class_name: 'Context', optional: true

    # include Swagger::Blocks
    #
    #
    #
    #
    #
    #
    # TODO: why does including the blocks here cause it not to be found in the apidocs controller? is it the module?

    ##
    # Transform a chaos Output object into a series of datapoints
    # "method":"POST","path":"/v6/Answer/Set","format":"json","controller":"ChaosApi::V6::AnswerController","action":"create","status":200,"duration":3.54,"view":0.06,"db":0.9,"params":{"questionId":"26:0:199","output":"{\"calibrationPoints\":{\"Pt1\":[{\"x\":350,\"y\":82,\"timeStamp\":1725843032922}],\"Pt2\":[{\"x\":1201,\"y\":78,\"timeStamp\":1725843034272}],\"Pt3\":[{\"x\":2323,\"y\":77,\"timeStamp\":1725843035464}],\"Pt6\":[{\"x\":2326,\"y\":500,\"timeStamp\":1725843036447}],\"Pt9\":[{\"x\":2323,\"y\":925,\"timeStamp\":1725843037740}],\"Pt8\":[{\"x\":1200,\"y\":916,\"timeStamp\":1725843038958}],\"Pt7\":[{\"x\":57,\"y\":923,\"timeStamp\":1725843040148}],\"Pt4\":[{\"x\":53,\"y\":500,\"timeStamp\":1725843041503}],\"Pt5\":[{\"x\":1194,\"y\":492,\"timeStamp\":1725843042595}]},\"Events\":[]}","sessionGUID":"f813af67-763a-449e-a366-aae7a35e71d8","userHTTPStatusCodes":"False"},"sql_queries":[{"name":"Chaos::ChaosSession Load","duration":0.24},{"name":"StudyDefinition Load","duration":0.07},{"name":"TrialDefinition Load","duration":0.15},{"name":"StudyResult::Stage Load","duration":0.15},{"name":"StudyResult::DataPoint Load","duration":0.29}],"sql_queries_count":5,"@timestamp":"2024-09-09T00:52:06.568Z","@version":"1","message":"[200] POST /v6/Answer/Set (ChaosApi::V6::AnswerController#create)"}
    def self.from_chaos_output(datapoint_address, output)
      new_datapoints = output['Events'].map do |event|
        kind = event['EventId'] || event['Id']
        entity_type = event['EntityType']
        dp_params = {
          point_type: event['Type'],
          entity_type: entity_type,
          kind: kind,
          value: event['Data'],
          method: event['Method'],
          datetime: event['DateTime']
        }
        dp_params = datapoint_address.merge(dp_params)
        DataPoint.new(dp_params)
      end

      state_dp_params = {
        entity_type: new_datapoints.first&.entity_type || '',
        kind: new_datapoints.first&.kind || '',
        point_type: 'State'
      }
      state_dp_params = datapoint_address.merge(state_dp_params)

      state = DataPoint.where(state_dp_params).first_or_initialize

      output.delete('Events')
      state.value = output.to_json
      state.datetime = DateTime.now

      new_datapoints << state
      new_datapoints
    end
  end
end
