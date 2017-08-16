class Study < ApplicationRecord
  has_one :user, foreign_key: "principal_investigator_user_id"

  include Swagger::Blocks

  swagger_schema :Study do
    key :required, [:principal_investigator_user_id, :title]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :title do
      key :type, :string
    end
    property :principal_investigator_user_id do
      key :type, :integer
      key :format, :int64
    end
  end
end
