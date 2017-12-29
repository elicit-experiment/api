module Api::V1
  class StudyResultsController < ApiController

    include StudyCreation

    include StudyResultConcern

    private

    def study_result_params
      permit_json_params(params[:study_result], :study_result) do
        params.require(:study_result).permit([
          :study_definition_id,
          :user_id
          ])
      end
    end
  end
end
