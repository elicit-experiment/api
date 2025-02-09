# frozen_string_literal: true

module ChaosApi
  module V6
    class TimeSeriesController < ChaosApiController

      WEBGAZER_HEADERS = %i[event x y clock_ms timeStamp
                            left_image_x left_image_y
                            left_width left_height
                            right_image_x right_image_y
                            right_width right_height].freeze

      MOUSE_HEADERS = %i[x y timeStamp].freeze

      HEADERS_SET = {
        webgazer: WEBGAZER_HEADERS,
        mouse: MOUSE_HEADERS
      }.freeze

      before_action :post_params, only: %i[create append]

      def create
        append
      end

      def append
        @response = ChaosResponse.new([])

        if @chaos_session.preview
          respond_to do |format|
            format.json { render json: @response.to_json }
          end

          if params[:points]
            # TODO
          elsif params[:file]
            # TODO
          else
            logger.debug params[:data].ai
          end

          return
        end

        # created is better but Chaos thinks it's an error
        # @response_status = :created
        @response_status = :ok

        if params[:points]
          append_tsv_from_json(time_series)
        elsif params[:file]
          append_tsv_from_file(time_series(mime_type_override: Mime::Type.lookup(params[:file].content_type || params[:mimeType]).symbol))
        else
          append_json_from_json(time_series)
        end

        @time_series.save!

        render json: @response.to_json, status: @response_status
      end

      # TODO: this being in the time series controller is an artifact of when all the mouse timeseries were handled as
      # individual datapoints. The codebase has progressed much since then, and now we only need this functionality for
      # the summary datapoint. Ideally we'd had a separate controller for this "send a datapoint" functionality since it's
      # logically unrelated to time series now.
      def summary
        @datapoint_query_fields = {
          stage_id: @chaos_session.stage&.id,
          protocol_user_id: @chaos_session.protocol_user_id,
          phase_definition_id: @chaos_session.stage&.phase_definition_id,
          trial_definition_id: @chaos_session.trial_result&.trial_definition_id,
          component_id: 0
        }

        fields = @datapoint_query_fields.merge(JSON.parse(params.permit(:content)[:content].to_s).symbolize_keys)

        if @chaos_session.preview
          @response = ChaosResponse.new([])
        else
          @data_point = StudyResult::DataPoint.create!(fields)
          @response = ChaosResponse.new([@data_point.id])
        end

        @response_status = :ok
        render json: @response.to_json, status: @response_status
      end

      private

      def append_tsv_from_json(time_series)
        @data = post_params[:points]

        append_text = @data.map do |row|
          @header_set.map { |col| row[col] }.join("\t")
        end.join("\n")

        time_series.append_string_to_tsv(append_text, @header_set)

        save_time_series(time_series)
      end

      def append_tsv_from_file(time_series)
        @file = post_params[:file]

        # check headers
        header = @file.tempfile.readline.chomp
        expected_header = @header_set.join("\t")
        if header != expected_header
          logger.warn "invalid header passed through file: #{header} vs. #{expected_header}"
          @response = ChaosResponse.new([], 'failed to save')
          @response_status = :unprocessable_entity
          return
        end

        # @file.tempfile.rewind

        # puts File.read(@file.tempfile.path)

        time_series.append_file_to_tsv(@file.tempfile, @header_set)

        save_time_series(time_series)
      end

      def append_json_from_json(time_series)
        time_series.append_data params[:data]

        save_time_series(time_series)
      end

      def save_time_series(time_series)
        unless time_series.save
          logger.error 'time series failed to save!'
          logger.error time_series.ai
          logger.error time_series.errors.full_messages.join("\n")
          @response = ChaosResponse.new([], 'failed to save')
          @response_status = :unprocessable_entity
        end

        logger.debug "Saved time series #{time_series.id}"
      end

      def time_series(mime_type_override: nil)
        return @time_series if @time_series.present?

        study_definition_id = @chaos_session.study_definition_id
        phase_definition_id = @chaos_session.phase_definition_id

        unprocessable_entity "invalid series type #{@series_type}" unless StudyResult::TimeSeries::SERIES_TYPES.include? @series_type.to_sym

        schema = StudyResult::TimeSeries.schema_for(series_type: @series_type, format: mime_type_override || request.content_mime_type.symbol)
        unsupported_media_type('Invalid series type/format combination', "#{@series_type}#{request.content_mime_type.symbol}") if schema.blank?

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

      def post_params
        # validate POST parameters
        @series_type = (params[:seriesType] || 'webgazer').to_sym
        @header_set = HEADERS_SET[@series_type]

        params.permit(:format, :sessionGUID, :data, :seriesType, :content, :series_type, :mimeType, :file, :userHTTPStatusCodes, points: @header_set)
      end
    end
  end
end
