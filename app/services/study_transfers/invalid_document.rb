# frozen_string_literal: true

module StudyTransfers
  class InvalidDocument < StandardError
    attr_reader :issues

    def initialize(issues)
      @issues = issues
      super('Document validation failed')
    end
  end
end
