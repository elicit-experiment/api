module Api::V1
  class StimuliController < ApiController

    include StudyCreation

    private

    def stimulus_params
      ap params.permit!
      permit_json_params(params[:stimulus], :stimulus) do
        params.require(:stimulus).permit(:definition_data)
      end
    end
  end
end
