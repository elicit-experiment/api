module Api::V1
  class StagesController < ApiController

    include StudyCreation

    include StudyResultConcern

    private

    def stage_params
      params.require([:study_definition_id, :protocol_definition_id, :phase_definition_id])
      permit_json_params(params[:data_point], :data_point) do
        origin = {:study_definition_id => params[:study_definition_id],
                  :protocol_definition_id => params[:protocol_definition_id],
                  :phase_definition_id => params[:phase_definition_id],
                 }
        params.require(:data_point).permit([
          :last_completed_trial,
          :num_trials,
          :point_type,
          :user_id,
          :context_id,
          ]).merge(origin)
      end
    end
  end
end
