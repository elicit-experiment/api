# frozen_string_literal: true

module StudyCreation
  extend ActiveSupport::Concern

  included do
    # Must have 'write' token
    before_action only: %i[update destroy] do # must be owner of study_definition being edited/deleted
      resource = get_resource

      authorize! :update_study_definition, resource, user: current_api_user
    end

    before_action only: %i[show index] do
      @study_definition = StudyDefinition.find(params[:study_definition_id]) if params[:study_definition_id].present?

      if @study_definition.blank?
        authorize! :read_study_definitions, StudyDefinition, user: current_api_user
      else
        authorize! :read_study_definitions, @study_definition, user: current_api_user
      end
    end

    before_action only: [:create] do # must be admin to create
      authorize! :create_studies, resource_name.classify.constantize
    end

    before_action :authenticate_user!
    #  before_action :doorkeeper_authorize!, except: [:show]
    #  before_action -> { doorkeeper_authorize! :write }, only: [:create, :update, :destroy]
  end
end
