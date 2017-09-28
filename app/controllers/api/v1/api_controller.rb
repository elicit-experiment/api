module Api::V1
  class ApiController < ApplicationController
    prepend_before_action :set_resource, only: [:destroy, :show, :update]

    respond_to :json

    # Returns the resource from the created instance variable
    # @return [Object]
    def get_resource
      instance_variable_get("@#{resource_name}")
    end

    # Returns the allowed parameters for searching
    # Override this method in each API controller
    # to permit additional parameters to search on
    # @return [Hash]
    def query_params
      {}
    end

    def search_param
      nil
    end

    def page_params
      if action_name == "index"
        page = params[:page] || 1
        page_size = params[:page_size] || 20
        { :page => page, :page_size => page_size}
      end
    end

    def eager_load_fields
      nil
    end

    # POST /api/{plural_resource_name}
    def create
      set_resource(resource_class.new(resource_params))

      if get_resource.save
        render json: get_resource, status: :created
      else
        render json: get_resource.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/{plural_resource_name}/:id
    def destroy
      get_resource.destroy
      head :no_content
    end

    # GET /api/{plural_resource_name}
    def index
      plural_resource_name = "@#{resource_name.pluralize}"
      if not query_params.nil?
        resources = resource_class.where(query_params)
      end
      if not search_param.nil?
        resources = resource_class.full_text_search(search_param)
      end
      if not eager_load_fields.nil?
        eager_load_fields.each do |e|
          resources = resources.includes(*e)
        end
      end

      if not page_params.nil?
        resources = resources.page(page_params[:page])
                                  .per(page_params[:page_size])
      end
      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name)
    end

    # GET /api/{plural_resource_name}/:id
    def show
      respond_with get_resource
    end

    # PATCH/PUT /api/{plural_resource_name}/1
    def update
      if get_resource.update(resource_params)
        render json: get_resource, status: :ok
      else
        render json: get_resource.errors, status: :unprocessable_entity
      end
    end

    def not_found(message = "object not found")
      raise ElicitError.new(message, :not_found)
    end

    def unprocessable_entity(message = "object not found")
      raise ElicitError.new(message, :unprocessable_entity)
    end

    def permission_denied
      raise ElicitError.new("permission denied", :unauthorized)
    end


    private

    # The singular name for the resource class based on the controller
    # @return [String]
    def resource_name
      @resource_name ||= self.controller_name.singularize
    end

    # The resource class based on the controller
    # @return [Class]
    def resource_class
      @resource_class ||= resource_name.classify.constantize
    end

    # Only allow a trusted parameter "white list" through.
    # If a single resource is loaded for #create or #update,
    # then the controller for the resource must implement
    # the method "#{resource_name}_params" to limit permitted
    # parameters for the individual model.
    def resource_params
      @resource_params ||= self.send("#{resource_name}_params")
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_resource(resource = nil)
      resource ||= resource_class.find(params[:id]) or not_found
      instance_variable_set("@#{resource_name}", resource)
    end

    def permit_json_params(hash, key)
      json_values = hash.delete(key)
      permitted_params = yield
      permitted_params[key] = json_values if json_values
      permitted_params
    end

  end
end
