class ProtocolUser < ApplicationRecord
  belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
  has_one :study_definition, :through => :protocol_definition
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"

  has_one :experiment, :class_name => "StudyResult::Experiment", :dependent => :destroy

  scope :by_protocol_definition, -> (protocol_definition_id) {where(protocol_definition_id: protocol_definition_id)}

  scope :free_for_anonymous, -> (protocol_definition_id) {
    where(protocol_definition_id: protocol_definition_id)
        .joins(:user)
        .left_outer_joins(:experiment)
        .where({:study_result_experiments => {protocol_user_id: nil},
                :users => {role: User::ROLES[:anonymous]}})
  }
  scope :for_user, -> (protocol_definition_id, user_id) {
    where({:user_id => user_id,
           :protocol_definition_id => protocol_definition_id})
        .includes(:protocol_definition)
  }

  include Swagger::Blocks

  swagger_schema :ProtocolUser do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
    end
    property :group_name do
      key :type, :string
    end
    property :protocol_definition_id do
      key :type, :integer
      key :format, :int64
    end
  end
end
