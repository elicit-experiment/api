# frozen_string_literal: true

module Api
  module V1
    class StudyResultsController < StudyResultsBaseController

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
