module StudyCreation

  extend ActiveSupport::Concern

  included do
    # Must have 'write' token
    before_action only: [:update, :destroy] do # must be owner of study_definition being edited/deleted
      resource = get_resource
      if resource.principal_investigator_user_id != current_api_user_id
       Rails.logger.error "Attempt to modify study owned by #{resource.principal_investigator_user_id} by #{current_api_user_id}"
       permission_denied
      end
    end

    before_action only: [:create] do # must be admin to create
      if current_api_user.role != 'admin'
        Rails.logger.error "Attempt to create study component by #{current_api_user.id} who is a #{current_api_user.role}"
        permission_denied
      end
    end

    before_action :authenticate_user!
    #  before_action :doorkeeper_authorize!, except: [:show]
    #  before_action -> { doorkeeper_authorize! :write }, only: [:create, :update, :destroy]
  end
end
