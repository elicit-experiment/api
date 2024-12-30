# frozen_string_literal: true

module Api
  module V1
    module TimeSeries
      class ContentController < ApplicationController
        include Authenticatable
        include ElicitErrors
        include StudyResultConcern
        include ActionController::MimeResponds
        include ActionController::Live

        respond_to :tsv, :csv, :json

        SEARCH_FIELDS = %i[stage_id study_definition_id protocol_definition_id
                           phase_definition_id trial_definition_id].freeze

        def query_params
          {}
        end

        def show
          time_series = StudyResult::TimeSeries.find(params[:time_series_id])

          query_params = {
            user_name: params[:user_name],
            group_name: params[:group_name],
            session_name: params[:session_name],
            trial_definition_id: params[:trial_definition_id]
          }.compact

          if query_params.blank?
            logger.debug 'No query params, using default'

            # TODO: consider send_file here
            # [Accelerated Rails Downloads with NGINX | mattbrictson.com](https://mattbrictson.com/accelerated-rails-downloads)
            # file_name = Rails.root.join(time_series.file.path)
            # send_file(file_name, :type => "text/tab-separated-values")

            response_body = File.open(time_series.file.path, 'r')
          else
            logger.debug "Query params: #{query_params.to_json}"
            parser_class_name = Rails.configuration.time_series_schema[time_series.schema]['plugin_class']

            parser_class = parser_class_name.classify.constantize

            parser = parser_class.new(time_series.schema_metadata)

            response_body = parser.query(time_series, query_params)
          end

          headers['X-Accel-Buffering'] = 'no'
          headers['Cache-Control'] = 'no-cache'
          headers['Last-Modified'] = Time.zone.now.ctime.to_s

          respond_to do |format|
            format.tsv do
              csv_filename = 'query.tsv'
              headers['Content-Type'] = 'text/tab-separated-values; charset=utf-8'
              self.content_type ||= Mime::TSV
              headers['Content-Disposition'] =
                %(attachment; filename="#{csv_filename}")
              headers['Last-Modified'] = Time.zone.now.ctime.to_s

              stream_file(response_body)
            end
            format.json do
              filename = 'query.json'

              headers['Content-Type'] = 'application/ld+json; charset=utf-8'
              self.content_type ||= Mime::TSV
              headers['Content-Disposition'] =
                %(attachment; filename="#{filename}")

              stream_file(response_body)
            end
          end
        end

        private

        def stream_file(response_body)
          response_body.rewind
          while (chunk = response_body.read(2**16))
            response.stream.write(chunk)
          end

          response.stream.close
        end
      end
    end
  end
end
