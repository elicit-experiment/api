module Api::V1
  class StudyDefinitionsController < ApiController

    # Must have 'write' token
    before_action only: [:update, :destroy] do # must be owner of study_definition being edited/deleted
      resource = get_resource
      if resource.principal_investigator_user_id != current_user.id #current_resource_owner
        permission_denied
      end
    end

    before_action :authenticate_user!
  #  before_action :doorkeeper_authorize!, except: [:show]
  #  before_action -> { doorkeeper_authorize! :write }, only: [:create, :update, :destroy]

    def index
      super
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

    def study_definition_params
      #ap params
      permit_json_params(params[:study_definition], :foo) do
        params.require(:study_definition).permit(:principal_investigator_user_id)#.merge(:principal_investigator_user_id => current_resource_owner)
      end
    end
  end
end
