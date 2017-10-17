module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class Context < ApplicationRecord
    has_many :study_result_data_points

    include Swagger::Blocks

    swagger_schema :Context do
      property :id do
        key :type, :integer
        key :format, :int64
      end
      property :context_type do
        key :context_type, :string
        key :format, :string
      end
      property :data do
        key :type, :string
        key :format, :string
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
