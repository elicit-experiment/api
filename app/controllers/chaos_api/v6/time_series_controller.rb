# frozen_string_literal: true

class FileIO < StringIO
  def initialize(stream, filename)
    super(stream)
    @original_filename = filename
  end

  attr_reader :original_filename
end

module ChaosApi::V6
  class TimeSeriesController < ChaosApiController
    include ActionController::MimeResponds

    include ActionController::Cookies

    WEBGAZER_HEADERS = %i[event x y clock_ms timeStamp
                          left_image_x left_image_y
                          left_width left_height
                          right_image_x right_image_y
                          right_width right_height].freeze

    def create
      @response = ChaosResponse.new([])
      @series_type = params[:series_type] || 'webgazer'

      if @chaos_session.preview
        respond_to do |format|
          format.json { render json: @response.to_json }
        end

        return
      end

      time_series = get_time_series

      @response_status = :created

      if params[:points]
        append_from_json(time_series)
      elsif params[:file]
        append_from_file(time_series)
      end

      render json: @response.to_json, status: @response_status
    end

    def append
      @response = ChaosResponse.new([])
      @series_type = params[:series_type] || 'webgazer'

      if @chaos_session.preview
        respond_to do |format|
          format.json { render json: @response.to_json }
        end

        return
      end

      time_series = get_time_series

      @response_status = :created

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
        WEBGAZER_HEADERS.map { |col| row[col] }.join("\t")
      end.join("\n")

      time_series.append_to_tsv(append_text, WEBGAZER_HEADERS, 'webgazer.tsv')

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
      @file = params[:file]

      # check headers
      header = @file.tempfile.readline.chomp
      if header != WEBGAZER_HEADERS.join("\t")
        logger.warn "invalid header passed through file: #{header}"
        @response = ChaosResponse.new([], 'failed to save')
        @response_status = :unprocessable_entity
        return
      end

      # @file.tempfile.rewind

      # puts File.read(@file.tempfile.path)

      time_series.append_file_to_tsv(@file.tempfile, WEBGAZER_HEADERS, 'webgazer.tsv')

      unless time_series.save
        logger.error 'time series failed to save!'
        logger.error time_series.ai
        logger.error time_series.errors.full_messages.join("\n")
        @response = ChaosResponse.new([], 'failed to save')
        @response_status = :unprocessable_entity
      end

      logger.debug "Saved time series #{time_series.id}"
    end

    def get_time_series
      study_definition_id = @chaos_session.study_definition_id
      phase_definition_id = @chaos_session.phase_definition_id

      time_series_params = {
        stage_id: @chaos_session.stage_id,
        study_definition_id: study_definition_id,
        protocol_definition_id: @chaos_session.protocol_definition_id,
        phase_definition_id: phase_definition_id,
        schema: @series_type + '_tsv',
        schema_metadata: nil
      }

      StudyResult::TimeSeries.where(time_series_params).first_or_initialize
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
      params.permit(:format, :sessionGUID, :series_type, :file, points: WEBGAZER_HEADERS)
    end
  end
end
