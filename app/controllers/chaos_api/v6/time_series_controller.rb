# frozen_string_literal: true

class FileIO < StringIO
  def initialize(stream, filename)
    super(stream)
    @original_filename = filename
  end

  attr_reader :original_filename
end

module ChaosApi
  module V6
    class TimeSeriesController < ChaosApiController
      include ActionController::MimeResponds

      include ActionController::Cookies

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

          return
        end

        # created is better but Chaos thinks it's an error
        # @response_status = :created
        @response_status = :ok

        if params[:points]
          append_from_json(time_series)
        elsif params[:file]
          append_from_file(time_series)
        end

        render json: @response.to_json, status: @response_status
      end

      private

      def append_from_json(time_series)
        @data = post_params[:points]

        append_text = @data.map do |row|
          @header_set.map { |col| row[col] }.join("\t")
        end.join("\n")

        time_series.append_to_tsv(append_text, @header_set, "#{@series_type}.tsv")

        unless time_series.save
          logger.error 'time series failed to save!'
          logger.error time_series.ai
          logger.error time_series.errors.full_messages.join("\n")
          @response = ChaosResponse.new([], 'failed to save')
          @response_status = :unprocessable_entity
        end

        logger.debug "Saved time series #{time_series.id}"
      end

      def append_from_file(time_series)
        @file = post_params[:file]

        # check headers
        header = @file.tempfile.readline.chomp
        if header != @header_set.join("\t")
          logger.warn "invalid header passed through file: #{header}"
          @response = ChaosResponse.new([], 'failed to save')
          @response_status = :unprocessable_entity
          return
        end

        # @file.tempfile.rewind

        # puts File.read(@file.tempfile.path)

        time_series.append_file_to_tsv(@file.tempfile, @header_set, "#{@series_type}.tsv")

        unless time_series.save
          logger.error 'time series failed to save!'
          logger.error time_series.ai
          logger.error time_series.errors.full_messages.join("\n")
          @response = ChaosResponse.new([], 'failed to save')
          @response_status = :unprocessable_entity
        end

        logger.debug "Saved time series #{time_series.id}"
      end

      def time_series
        return @time_series if @time_series.present?

        study_definition_id = @chaos_session.study_definition_id
        phase_definition_id = @chaos_session.phase_definition_id

        unprocessable_entity "invalid series type #{@series_type}" unless StudyResult::TimeSeries::SERIES_TYPES.include? @series_type

        time_series_params = {
          stage_id: @chaos_session.stage_id,
          study_definition_id: study_definition_id,
          protocol_definition_id: @chaos_session.protocol_definition_id,
          phase_definition_id: phase_definition_id,
          schema: "#{@series_type}_tsv",
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
        @series_type = (params[:series_type] || 'webgazer').to_sym
        @header_set = HEADERS_SET[@series_type]

        params.permit(:format, :sessionGUID, :series_type, :file, points: @header_set)
      end
    end
  end
end
