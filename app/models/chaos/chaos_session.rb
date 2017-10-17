module Chaos
  class ChaosSession < ApplicationRecord
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"
    belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
    belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
    belongs_to :phase_definition, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"
    belongs_to :experiment, :class_name => "StudyResult::Experiment", :foreign_key => "experiment_id"
    belongs_to :stage, :class_name => StudyResult::Stage, :foreign_key => "stage_id"
  end
end
