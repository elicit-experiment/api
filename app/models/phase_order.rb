# frozen_string_literal: true

class PhaseOrder < ApplicationRecord
  belongs_to :study_definition, class_name: 'StudyDefinition'
  belongs_to :protocol_definition, class_name: 'ProtocolDefinition'
  belongs_to :user, class_name: 'User'

  def self.default_sequence(phases)
    phases.map(&:id).sort
  end

  include Swagger::Blocks

  swagger_schema :PhaseOrder do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
    end
    property :sequence_data do
      key :type, :string
    end
  end
end
