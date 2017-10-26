module StudyCreation

  extend ActiveSupport::Concern

  included do
    # Must have 'write' token
    before_action only: [:update, :destroy] do # must be owner of study_definition being edited/deleted
      resource = get_resource
      Rails.logger.info "Attempt to modify study owned by #{resource.principal_investigator_user_id} by #{current_user.id}"
      if resource.principal_investigator_user_id != current_user.id #current_resource_owner
        permission_denied
      end
    end

    before_action only: [:create] do # must be admin to create
      resource = get_resource
      Rails.logger.error "Attempt to create study component by #{current_user.id} who is a #{current_user.role}"
      if current_user.role != 'admin'
        permission_denied
      end
    end

    before_action :authenticate_user!
    #  before_action :doorkeeper_authorize!, except: [:show]
    #  before_action -> { doorkeeper_authorize! :write }, only: [:create, :update, :destroy]
  end
end
