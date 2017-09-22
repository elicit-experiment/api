module Api::V1
  class UsersController < ApiController

    # Must have 'write' token
    before_action only: [:update, :destroy] do # must be owner of study_definition being edited/deleted
      resource = get_resource
      Rails.logger.info "Attempt to modify user owned by #{resource.id} by #{current_user.id}"
      if resource.id != current_user.id #current_resource_owner
        permission_denied
      end
    end

    before_action :authenticate_user!
  #  before_action :doorkeeper_authorize!, except: [:show]
  #  before_action -> { doorkeeper_authorize! :write }, only: [:create, :update, :destroy]

    def index
      super
    end

    def show_current_user
      resource ||= resource_class.find(current_user.id) or not_found
      instance_variable_set("@#{resource_name}", resource)

      respond_with get_resource
    end

    def query_params
      super
    end

    def search_param
      super
    end

    def page_params
      if action_name == "index"
        page = params[:page] || 1
        page_size = params[:page_size] || 20
        { :page => page, :page_size => page_size}
      end
    end

    def eager_load_fields
      super
    end

    private

    def user_params
      ap params.permit!
      #ap params
      permit_json_params(params[:study_definition], :study_definition) do
        params.require(:study_definition).permit(:principal_investigator_user_id, :title)#.merge(:principal_investigator_user_id => current_resource_owner)
      end
    end
  end
end
