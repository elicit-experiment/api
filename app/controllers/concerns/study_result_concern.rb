# frozen_string_literal: true

module StudyResultConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!

    before_action only: %i[show index] do
      # Authorize nested routes under study_resuluts/:study_result_id via the study_result
      next if params[:study_result_id].blank?

      @study_result = StudyResult::StudyResult.find(params[:study_result_id])

      authorize! :read_study_results, @study_result, user: current_api_user
    end

    before_action only: %i[show] do
      authorize! :read_study_results, get_resource, user: current_api_user
    end
  end

  def resource_class
    @resource_class ||= "StudyResult::#{resource_name.classify}".constantize
  end
end
