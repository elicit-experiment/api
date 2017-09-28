module Api::V1
  class ProtocolDefinitionsController < ApiController

    include StudyCreation

    private

    def protocol_definition_params
      ap params.permit!
      params.require(:study_definition_id)
      permit_json_params(params[:protocol_definition], :protocol_definition) do
        params.require(:protocol_definition).permit(:definition_data).merge(:study_definition_id => params[:study_definition_id])
      end
    end
  end
end
