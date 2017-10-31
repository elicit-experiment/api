module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class Experiment < ApplicationRecord
    belongs_to :protocol_user, :class_name => "ProtocolUser", :foreign_key => "protocol_user_id"
    belongs_to :current_stage, :class_name => "StudyResult::Stage", :foreign_key => "current_stage_id"
    belongs_to :study_result, :class_name => "StudyResult::StudyResult", :foreign_key => "study_result_id"

    has_many :stages, :class_name => "StudyResult::Stage", :dependent => :delete_all
  end
end
