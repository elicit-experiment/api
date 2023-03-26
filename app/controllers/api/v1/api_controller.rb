# frozen_string_literal: true

module Api
  module V1
    class ApiController < ApplicationController
      include Authenticatable
      include ElicitErrors

      include PaginationHeaderLinks

      prepend_before_action :set_resource, only: %i[destroy show update]

      respond_to :json

      rescue_from ElicitError, with: :render_elicit_error

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

      def eager_load_fields
        nil
      end

      # POST /api/{plural_resource_name}
      def create
        set_resource(resource_class.new(resource_params))

        if get_resource.save
          render json: get_resource, status: :created
        else
          e = ElicitError.new('Cannot create user', :unprocessable_entity, details: resource.errors)

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
        unless query_params.nil?
          qp = query_params
          qp.delete_if { |_k, v| v.nil? }
          resources = resource_class.includes(send(:query_includes)).where(qp)
        end

        resources = resource_class.full_text_search(search_param) unless search_param.nil?

        eager_load_fields&.each do |e|
          resources = resources.includes(*e)
        end

        resources = resources.order(order_params)

        unless page_params.nil?
          resources = resources.page(page_params[:page])
                               .per(page_params[:page_size])
        end
        instance_variable_set(plural_resource_name, resources)
        respond_with instance_variable_get(plural_resource_name), include: send(:response_includes)

        set_pagination_headers instance_variable_get(plural_resource_name)
      end

      # GET /api/{plural_resource_name}/:id
      def show
        respond_with get_resource, include: send(:single_response_includes)
      end

      # PATCH/PUT /api/{plural_resource_name}/1
      def update
        if get_resource.update(resource_params)
          render json: get_resource, include: send(:single_response_includes), status: :ok
        else
          render json: get_resource.errors, status: :unprocessable_entity
        end
      end

      rescue_from CanCan::AccessDenied do |_exception|
        head :forbidden
      end

      protected

      # The includes for the query
      def query_includes
        {}
      end

      # The includes for the (JSON) response
      def response_includes
        []
      end

      # The includes for single queries
      def single_response_includes
        response_includes
      end

      def order_params
        order = params[:sort] == 'up' ? :asc : :desc
        { created_at: order }
      end

      private

      # The singular name for the resource class based on the controller
      # @return [String]
      def resource_name
        @resource_name ||= controller_name.singularize
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
        @resource_params ||= send("#{resource_name}_params")
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_resource(resource = nil)
        (resource ||= resource_class.find(params[:id])) || not_found
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
end
