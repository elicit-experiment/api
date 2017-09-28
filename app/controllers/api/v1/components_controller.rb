module Api::V1
  class ComponentsController < ApiController

    include StudyCreation

    private

    def stimulus_params
      ap params.permit!
      permit_json_params(params[:component], :component) do
        params.require(:component).permit(:definition_data)
      end
    end
  end
end
