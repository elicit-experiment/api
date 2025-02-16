# frozen_string_literal: true

module Api
  module V1
    class TimeSeriesController < StudyResultsBaseController
      include ActionController::MimeResponds

      respond_to :json

      SEARCH_FIELDS = %i[stage_id study_definition_id protocol_definition_id phase_definition_id trial_definition_id].freeze
      PAGE_PARAMS = %i[page page_size].freeze

      def query_params
        {}
      end

      def show
        @time_series = get_resource
      end

      def index
        plural_resource_name = "@#{resource_name.pluralize}"

        @search_params = search_params
        @query_clauses = query_clauses

        resources = StudyResult::TimeSeries.where(@query_clauses)
                                           .page(@search_params[:page])
                                           .per(@search_params[:page_size])

        puts resources.to_sql

        instance_variable_set(plural_resource_name, resources)
        @collection = instance_variable_get(plural_resource_name)
      end

      private

      def search_params
        params.permit(*SEARCH_FIELDS, *PAGE_PARAMS, :study_result_id)
      end

      def query_clauses
        search_ids = @search_params.to_h
                                   .keys
                                   .reject { |p| @search_params[p].blank? || p == 'study_result_id' } # :study_result_id is in the path, but not a column of the time series
                                   .select { |p| p.to_s.ends_with?('_id') }

        @search_params.slice(*search_ids)
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
