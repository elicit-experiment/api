module Api::V1
  class TrialResultsController < ApiController

    include StudyCreation

    include StudyResultConcern

    private

    def trial_result_params
      params.require([:study_result_id])
      permit_json_params(params[:trial_result], :trial_result) do
        origin = { :study_result_id => params[:study_result_id] }
        params.require(:trial_result).permit([
                                          :experiment_id,
                                          :protocol_user_id,
                                          :phase_definition_id,
                                          :trial_definition_id,
                                          :completed_at,
                                          :started_at
                                      ])#.merge(origin) (we don't have study_result_id in the schema)
      end
    end

    def query_params
      {
          :trial_definition_id => params[:trial_definition_id],
          :experiment_id => params[:experiment_id],
      }
    end
  end
end
