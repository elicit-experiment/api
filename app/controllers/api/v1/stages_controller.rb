module Api::V1
  class StagesController < ApiController

    include StudyCreation

    include StudyResultConcern

    private

    def stage_params
      params.require([:study_result_id])
      permit_json_params(params[:stage], :stage) do
        origin = { :study_result_id => params[:study_result_id] }
        params.require(:stage).permit([
          :experiment_id,
          :protocol_user_id,
          :phase_definition_id,
          :last_completed_trial,
          :current_trial,
          :num_trials,
          :context_id,
          :completed_at
          ])#.merge(origin)  (we don't have study_result_id in the schema)
      end
    end
  end
end
