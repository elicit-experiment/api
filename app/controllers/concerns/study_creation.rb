# frozen_string_literal: true

module StudyCreation
  extend ActiveSupport::Concern

  included do
    # Must have 'write' token
    before_action only: %i[update destroy] do # must be owner of study_definition being edited/deleted
      resource = get_resource
      if resource.principal_investigator_user_id != current_api_user_id && !current_api_user.is_admin?
        Rails.logger.error "Attempt to modify study owned by #{resource.principal_investigator_user_id} by #{current_api_user_id}"
        permission_denied
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
