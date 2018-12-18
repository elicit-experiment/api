require 'securerandom'

module Api::V1
  class StudyDefinitionsController < ApiController

    STUDY_DEFINITION_FIELDS = %w[
    principal_investigator_user_id
    title
    description
    version
    data
    lock_question
    enable_previous
    no_of_trials
    footer_label
    redirect_close_on_url
    allow_anonymous_users
    show_in_study_list
    max_anonymous_users
    ].map(&:to_sym)

    include StudyCreation

    def index
      plural_resource_name = "@#{resource_name.pluralize}"
      resources = StudyDefinition.includes(query_includes).joins(:principal_investigator).order({:created_at => :desc})

      if not page_params.nil?
        resources = resources.page(page_params[:page])
                        .per(page_params[:page_size])
      end
      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name), :include => response_includes
    end

    private

    def query_includes
      {:protocol_definitions => :phase_definitions}
    end

    def response_includes
      [:principal_investigator, {:protocol_definitions => {:include => :phase_definitions}}]
    end

    def study_definition_params
      permit_json_params(params[:study_definition], :study_definition) do
        params.require(:study_definition).permit(STUDY_DEFINITION_FIELDS)
      end
    end
  end
end
