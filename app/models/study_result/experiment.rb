module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class Experiment < ApplicationRecord
    belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
    has_one :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id", :through => :protocol_user
    has_one :user, :class_name => "User", :foreign_key => "user_id", :through => :protocol_user
    belongs_to :protocol_user, :class_name => "ProtocolUser", :foreign_key => "protocol_user_id"

    has_many :study_result_stages, :dependent => :delete_all

    include Swagger::Blocks

    swagger_schema :Experiment do
      property :id do
        key :type, :integer
        key :format, :int64
      end
      property :user_id do
        key :type, :integer
        key :format, :int64
      end
      property :study_definition_id do
        key :type, :integer
        key :format, :int64
      end
      property :protocol_definition_id do
        key :type, :integer
        key :format, :int64
      end
      property :started_at do
        key :type, :string
        key :format, :datetime
      end
      property :completed_at do
        key :type, :string
        key :format, :datetime
      end
    end
  end
end
