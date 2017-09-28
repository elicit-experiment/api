module Api::V1
  class StudyDefinitionsController < ApiController

    include StudyCreation

    private

    def study_definition_params
      ap params.permit!
      permit_json_params(params[:study_definition], :study_definition) do
        params.require(:study_definition).permit(:principal_investigator_user_id, :title)
      end
    end
  end
end
