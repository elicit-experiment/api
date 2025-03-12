# frozen_string_literal: true

require 'securerandom'

module Api
  module V1

    class StudyDefinitionsController < ApiController
      STUDY_DEFINITION_FIELDS = %i[
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
        auto_created_user_count
        max_auto_created_users
        max_concurrent_users
      ].freeze

      include StudyCreation

      def index
        plural_resource_name = "@#{resource_name.pluralize}"

        if current_user.role == User::ROLES[:admin]
          root_scope = StudyDefinition.all
        elsif current_user.role == User::ROLES[:investigator]
          root_scope = StudyDefinition.where(principal_investigator_user_id: current_api_user.id)
        end

        resources = root_scope.includes(query_includes).joins(:principal_investigator).order(created_at: :desc)

        unless page_params.nil?
          resources = resources.page(page_params[:page])
                               .per(page_params[:page_size])
        end

        instance_variable_set(plural_resource_name, resources)
        respond_with instance_variable_get(plural_resource_name), include: response_includes

        set_pagination_headers instance_variable_get(plural_resource_name), root_scope, page_params
      end

      def create
        logger.info study_definition_params
        if current_user.role != User::ROLES[:admin] && study_definition_params[:principal_investigator_user_id] != current_user.id
          Rails.logger.error "Attempt to create study component not owned by callee #{current_api_user.id}"
          permission_denied
        end

        super
      end

      private

      def query_includes
        { protocol_definitions: :phase_definitions }
      end

      def response_includes
        [:principal_investigator, { protocol_definitions: { include: :phase_definitions } }]
      end

      def single_response_includes
        [:principal_investigator, { protocol_definitions: { include: [:phase_definitions, { protocol_users: { include: %i[user experiment] } }] } }]
      end

      def study_definition_params
        permitted_params = permit_json_params(params[:study_definition], :study_definition) do
          params.require(:study_definition).permit(STUDY_DEFINITION_FIELDS).with_defaults(principal_investigator_user_id: current_user.id)
        end
      end
    end
  end
end
