# frozen_string_literal: true

module Api
  module V1
    class StagesController < ApiController
      include StudyCreation

      include StudyResultConcern

      private

      def stage_params
        params.require([:study_result_id])
        permit_json_params(params[:stage], :stage) do
          origin = { study_result_id: params[:study_result_id] }
          params.require(:stage).permit(%i[
                                          experiment_id
                                          protocol_user_id
                                          phase_definition_id
                                          last_completed_trial
                                          current_trial
                                          num_trials
                                          context_id
                                          started_at
                                          completed_at
                                        ]) # .merge(origin)  (we don't have study_result_id in the schema)
        end
      end

      def query_params
        {
          #        :phase_definition_id => params[:phase_definition_id],
          experiment_id: params[:experiment_id]
        }
      end
    end
  end
end
