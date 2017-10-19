module Api::V1
  class ExperimentsController < ApiController

    include StudyCreation

    include StudyResultConcern

    private

    def experiment_params
      params.require([:study_definition_id, :protocol_definition_id])
      permit_json_params(params[:data_point], :data_point) do
        origin = {:study_definition_id => params[:study_definition_id],
                  :protocol_definition_id => params[:protocol_definition_id],
                 }
        params.require(:data_point).permit([
          :user_id,
          ]).merge(origin)
      end
    end
  end
end
