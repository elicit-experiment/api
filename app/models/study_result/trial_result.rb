module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class TrialResult < ApplicationRecord
    belongs_to :experiment, :class_name => "StudyResult::Experiment", :foreign_key => "experiment_id"
    belongs_to :protocol_user, :class_name => "ProtocolUser", :foreign_key => "protocol_user_id"
    belongs_to :phase_definition, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"
    belongs_to :trial_definition, :class_name => "TrialDefinition", :foreign_key => "Trial_definition_id"

    #has_many :data_points, :class_name => "StudyResult::DataPoint", :dependent => :delete_all
  end
end
