# frozen_string_literal: true

module ChaosApi
  module V6
    class UnauthorizedError < StandardError; end

    class TimeSeriesRawController < ActionController::Metal
      include ActionController::MimeResponds
      include ActionController::Cookies
      include ActionController::Head
      include ElicitErrors

      # This, and the respond_with in append, don't work to send the correct types.
      # include ActionController::RespondWith
      # respond_to :json

      def append
        fake_request_params

        ensure_session
        @series_type = request.path.match(%r{/v6/time_series/(?<series_type>[a-z_]+)/file_raw(?<ext>\.json)?})[:series_type]&.to_sym
        @response = ChaosResponse.new([])

        return append_preview if @chaos_session.preview

        # created is better but Chaos thinks it's an error
        # @response_status = :created
        @response_status = :ok

        append_json(time_series, request.raw_post)

        @time_series.save!

        add_json_response_header
        self.response_body = @response.to_json
        self.status = @response_status
      rescue UnauthorizedError
        self.status = :unauthorized
      rescue ElicitError => error
        add_json_response_header
        self.response_body = error.to_json
        self.status = error.code
      end

      # don't parse the params
      def params
        nil
      end

      private

      def add_json_response_header
        response.headers['Content-Type'] = [Mime::Type.lookup_by_extension(:json).to_s, 'charset=utf-8'].join('; ')
      end

      def append_preview
        fake_request_params

        request.raw_post.split("\n").each do |line|
          # puts line
          unless line.start_with?('{"')
            self.response_body = { error: 'incorrect line' }.to_json
            self.status = :bad_request
            return
          end
        end

        @response_status = :ok
        add_json_response_header
        self.response_body = @response.to_json
        self.status = @response_status
      end

      def ensure_session
        session_guid = request.headers['X-CHAOS-SESSION-GUID']

        @chaos_session = Chaos::ChaosSession.find_by(session_guid: session_guid)

        raise UnauthorizedError unless @chaos_session
      end

      def append_json(time_series, blob)
        time_series.append_raw(blob)

        save_time_series(time_series)
      end

      def save_time_series(time_series)
        time_series.validate_in_progress_file unless Rails.env.production?

        unless time_series.save
          logger.error 'time series failed to save!'
          logger.error time_series.ai
          logger.error time_series.errors.full_messages.join("\n")
          @response = ChaosResponse.new([], 'failed to save')
          @response_status = :unprocessable_entity
        end

        Rails.logger.debug "Saved time series #{time_series.id}"
      end

      def time_series
        return @time_series if @time_series.present?

        study_definition_id = @chaos_session.study_definition_id
        phase_definition_id = @chaos_session.phase_definition_id

        unprocessable_entity "invalid series type #{@series_type}" unless StudyResult::TimeSeries::SERIES_TYPES.include? @series_type.to_sym

        schema = StudyResult::TimeSeries.schema_for(series_type: @series_type, format: request.content_mime_type.symbol)
        unsupported_media_type('Invalid series type/format combination', "#{@series_type}_#{request.content_mime_type.symbol}") if schema.blank?

        time_series_params = {
          stage_id: @chaos_session.stage_id,
          study_definition_id: study_definition_id,
          protocol_definition_id: @chaos_session.protocol_definition_id,
          phase_definition_id: phase_definition_id,
          schema: schema,
          schema_metadata: nil
        }

        @time_series = StudyResult::TimeSeries.where(time_series_params).first_or_initialize
      end

      def respond_error(msg, status = :unprocessable_entity)
        @response = ChaosResponse.new([], msg)
        respond_to do |format|
          format.xml { render xml: @response.to_xml, status: status }
          format.json { render json: @response.to_json, status: status }
        end
      end

      def fake_request_params
        request.env['action_dispatch.request.parameters'] = {}
      end

    end
  end
end
