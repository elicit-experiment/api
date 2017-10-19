module Api::V1
  class StudyResultsController < ApiController

    include StudyCreation

    include StudyResultConcern

    private

    def study_result_params
      params.require([:study_definition_id, :protocol_definition_id])
      permit_json_params(params[:study_result], :study_result) do
        origin = {:study_definition_id => params[:study_definition_id],
                }
        params.require(:study_result).permit([
          :user_id,
          ]).merge(origin)
      end
    end
  end
end
