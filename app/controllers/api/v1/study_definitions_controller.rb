require 'securerandom'

module Api::V1
  class StudyDefinitionsController < ApiController

    include StudyCreation

    def index
      plural_resource_name = "@#{resource_name.pluralize}"
      resources = StudyDefinition.joins(:principal_investigator)

      ap resources

      if not page_params.nil?
        resources = resources.page(page_params[:page])
                                  .per(page_params[:page_size])
      end
      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name), :include => :principal_investigator
    end

    def take
      session_guid = SecureRandom.uuid
      study_definition_id = params[:study_definition_id]
      ap Rails.configuration.elicit
      session_params = {
        :user_id => current_user.id,
        :session_guid => session_guid,
        :url => "http://#{Rails.configuration.elicit['participant_frontend']['host']}:#{Rails.configuration.elicit['participant_frontend']['port']}/?session_guid=#{session_guid}#Experiment/#{study_definition_id}",
        :expires_at => Date.today + 1.day
      }
      session = Chaos::ChaosSession.new(session_params)
      if session.save
        respond_with session
      else
        render json: ElicitError.new("Failed to create session", :unprocessable_entity), status: :unprocessable_entity
      end
    end

    private

    def study_definition_params
      permit_json_params(params[:study_definition], :study_definition) do
        params.require(:study_definition).permit(:principal_investigator_user_id, :title, :description, :version, :data, :lock_question, :enable_previous, :no_of_trials, :footer_label, :redirect_close_on_url)
      end
    end
  end
end
