# frozen_string_literal: true

module Api
  module V1
    class DataPointsController < ApiController
      include StudyCreation

      include StudyResultConcern

      SEARCH_FIELDS = %i[study_id protocol_user_id phase_definition_id trial_definition_id component_id protocol_user_id trial_definition_id].freeze
      PAGE_PARAMS = %i[page page_size].freeze

      def index
        plural_resource_name = "@#{resource_name.pluralize}"

        permitted_params = params.permit(*SEARCH_FIELDS, *PAGE_PARAMS, :study_result_id, :format)
        filter_fields = permitted_params.slice(*SEARCH_FIELDS).compact

        logger.info message: 'Datapoint filter', filter_fields: filter_fields

        resources = StudyResult::DataPoint.where(filter_fields)
                                          .includes(:component)
                                          .page(permitted_params[:page])
                                          .per(permitted_params[:page_size])

        # cols = StudyResult::DataPoint.column_names.map(&:to_sym)
        # ap cols

        resources = resources.map do |dp|
          h = dp.as_json
          h[:component_name] = dp.component.name if dp.component.present?
          h
        end

        instance_variable_set(plural_resource_name, resources)
        respond_with instance_variable_get(plural_resource_name)
      end

      def default_page_size
        100
      end

      private

      def data_point_params
        params.require([:stage_id]).permit(%i[protocol_user_id phase_definition_id trial_definition_id component_id])
        permit_json_params(params[:data_point], :data_point) do
          origin = {
            stage_id: params[:stage_id],
            protocol_user_id: params[:protocol_user_id],
            phase_definition_id: params[:phase_definition_id],
            trial_definition_id: params[:trial_definition_id],
            component_id: params[:component_id]
          }
          params.require(:data_point).permit(%i[
                                               kind
                                               point_type
                                               entity_type
                                               value
                                               method
                                               datetime
                                             ]).merge(origin)
        end
      end
    end
  end
end
