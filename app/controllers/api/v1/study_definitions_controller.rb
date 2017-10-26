require 'securerandom'

module Api::V1
  class StudyDefinitionsController < ApiController

    include StudyCreation

    def index
      plural_resource_name = "@#{resource_name.pluralize}"
      resources = StudyDefinition.includes(:protocol_definitions).joins(:principal_investigator)

      if not page_params.nil?
        resources = resources.page(page_params[:page])
                                  .per(page_params[:page_size])
      end
      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name), :include => [:principal_investigator, :protocol_definitions]
    end

   private

    def study_definition_params
      permit_json_params(params[:study_definition], :study_definition) do
        params.require(:study_definition).permit(:principal_investigator_user_id, :title, :description, :version, :data, :lock_question, :enable_previous, :no_of_trials, :footer_label, :redirect_close_on_url)
      end
    end
  end
end
