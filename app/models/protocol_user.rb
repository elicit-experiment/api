class ProtocolUser < ApplicationRecord
  belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"

  include Swagger::Blocks

  swagger_schema :ProtocolUser do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :user_id do
      key :type, :integer
    end
    property :protocol_definition_id do
      key :type, :integer
    end
  end
end