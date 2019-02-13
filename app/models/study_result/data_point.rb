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

    include Swagger::Blocks

    # TODO: why does including the blocks here cause it not to be found in the apidocs controller? is it the module?

  end
end
