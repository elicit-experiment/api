module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class DataPoint < ApplicationRecord
    belongs_to :protocol_user, :class_name => "ProtocolUser", :foreign_key => "protocol_user_id"
    belongs_to :phase_definition, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"
    belongs_to :trial_definition, :class_name => "TrialDefinition", :foreign_key => "trial_definition_id"
    belongs_to :stage, :class_name => "Stage", :foreign_key => "stage_id"
    belongs_to :component, :class_name => "Component", :foreign_key => "component_id"
    belongs_to :context, :class_name => "Context", :foreign_key => "context_id", :optional => true

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
    def self.from_chaos_output(datapoint_address, output)
      new_datapoints = output["Events"].map do |event|
        kind = event["EventId"] || event['Id']
        entity_type = event['EntityType']
        dp_params = {
            :point_type => event["Type"],
            :entity_type => entity_type,
            :kind => kind,
            :value => event["Data"],
            :method => event["Method"],
            :datetime => event["DateTime"]
        }
        dp_params = datapoint_address.merge(dp_params)
        DataPoint.new(dp_params)
      end

      state_dp_params = {
          :entity_type => new_datapoints.first&.entity_type || '',
          :kind => new_datapoints.first&.kind || '',
          :point_type => 'State'
      }
      state_dp_params = datapoint_address.merge(state_dp_params)

      state = DataPoint.where(state_dp_params).first_or_initialize

      output.delete("Events")
      state.value = output.to_json
      state.datetime = DateTime.now

      new_datapoints << state
      new_datapoints
    end

  end
end
