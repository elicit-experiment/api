# frozen_string_literal: true

module Api
  module V1
    class TimeSeriesController < ApiController
      include StudyCreation

      include StudyResultConcern

      include ActionController::MimeResponds

      respond_to :json

      SEARCH_FIELDS = %i[stage_id study_definition_id protocol_definition_id
                         phase_definition_id trial_definition_id].freeze

      def query_params
        {}
      end

      def show
        @time_series = get_resource
      end

      def index
        plural_resource_name = "@#{resource_name.pluralize}"

        where = search_params
        logger.info "Search for time series with #{where.ai}"

        resources = StudyResult::TimeSeries.where(where)

        unless page_params.nil?
          resources = resources.page(page_params[:page])
                               .per(page_params[:page_size])
        end
        instance_variable_set(plural_resource_name, resources)
        @collection = instance_variable_get(plural_resource_name)
      end

      private

      def search_params
        permitted_params = params.permit(SEARCH_FIELDS)
        logger.info "perm param #{permitted_params.to_h.ai}"
        permitted_params.to_h
                        .keys
                        .reject { |p| params[p].blank? }
                        .select { |p| p.to_s.ends_with?('_id') }
                        .map { |p| { p.to_sym => params[p] } }
                        .reduce(&:merge)
      end

      def time_series_params
        params.permit!
        permit_json_params(params[:time_series], :time_series) do
          time_series_params = params.require(:time_series)
          pep = time_series_params.permit(%i[file
                                             study_definition_id
                                             protocol_definition_id
                                             phase_definition_id
                                             component_definition_id
                                             stage_id
                                             schema
                                             schema_metadata])
          pep
        end
      end
    end
  end
end
