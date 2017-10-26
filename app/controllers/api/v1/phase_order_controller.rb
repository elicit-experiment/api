module Api::V1
  class PhaseOrderController < ApiController

    include StudyCreation

    private

    def phase_order_params
      params.require([:study_definition_id, :protocol_definition_id])
      permit_json_params(params[:phase_order], :phase_order) do
        path_params = {
                        :study_definition_id => params[:study_definition_id],
                        :protocol_definition_id => params[:protocol_definition_id
                      ]}
        params.require(:phase_order).permit([:sequence_data,
                                              :user_id]).merge(path_params)
      end
    end
  end
end
