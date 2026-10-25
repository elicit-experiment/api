# frozen_string_literal: true

module Api
  module V1
    class StudyResultsController < StudyResultsBaseController
      def index
        root_scope = authorized_study_results
        filters = query_params.compact
        root_scope = root_scope.where(filters) if filters.present?

        resources = root_scope.includes(query_includes).order(order_params)
        resources = resources.page(page_params[:page]).per(page_params[:page_size]) unless page_params.nil?

        @study_results = resources
        respond_with @study_results, include: response_includes
        set_pagination_headers @study_results, root_scope, page_params
      end

      private

      def study_result_params
        permit_json_params(params[:study_result], :study_result) do
          params.require(:study_result).permit(%i[
                                                 study_definition_id
                                                 user_id
                                               ])
        end
      end

      def query_params
        { study_definition_id: params[:study_definition_id] }
      end
    end
  end
end
