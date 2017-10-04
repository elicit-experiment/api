module Api::V1
  class StudyDefinitionsController < ApiController

    include StudyCreation

    private

    def study_definition_params
      ap params.permit!
      permit_json_params(params[:study_definition], :study_definition) do
        params.require(:study_definition).permit(:principal_investigator_user_id, :title, :description, :version, :data, :lock_question, :enable_previous, :no_of_trials, :footer_label, :redirect_close_on_url)
      end
    end
  end
end
