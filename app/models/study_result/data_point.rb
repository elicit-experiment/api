module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class DataPoint < ApplicationRecord
    belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
    belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
    belongs_to :phase_definition, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"
    belongs_to :trial_definition, :class_name => "TrialDefinition", :foreign_key => "trial_definition_id"
    belongs_to :component, :class_name => "StudyResult::Component", :foreign_key => "component_id"
    belongs_to :context, :class_name => "StudyResult::Context", :foreign_key => "context_id"
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  end
end
