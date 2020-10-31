# frozen_string_literal: true

module Api::V1
  class ExperimentsController < ApiController
    include StudyCreation

    include StudyResultConcern

    def query_includes
      { protocol_user: :user }
    end

    def response_includes
      { protocol_user: { include: :user } }
    end

    private

    def experiment_params
      params.require([:study_result_id])
      permit_json_params(params[:experiment], :experiment) do
        origin = { study_result_id: params[:study_result_id] }
        params.require(:experiment).permit(%i[
                                             protocol_user_id
                                             current_stage_id
                                             num_stages_completed
                                             num_stages_remaining
                                             started_at
                                             completed_at
                                           ]).merge(origin)
      end
    end

    def query_params
      { study_result_id: params[:study_result_id] }
    end
  end
end
