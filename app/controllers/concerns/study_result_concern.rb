# frozen_string_literal: true

module StudyResultConcern
  def resource_class
    @resource_class ||= ('StudyResult::' + resource_name.classify).constantize
  end
end
