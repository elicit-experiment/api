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
                          right_width right_height]

    def create
      @response = ChaosResponse.new([])
      @series_type = params[:series_type] || 'webgazer'
      @data = post_params[:points]

      if @chaos_session.preview
        respond_to do |format|
          format.xml { render :xml => '' }
          format.json { render :json => @response.to_json }
        end

        return
      end

      #logger.info @chaos_session.ai

      study_definition_id = @chaos_session.study_definition_id
      phase_definition_id = @chaos_session.phase_definition_id

      time_series_params = {
          stage_id: @chaos_session.stage_id,
          study_definition_id: study_definition_id,
          protocol_definition_id: @chaos_session.protocol_definition_id,
          phase_definition_id: phase_definition_id,
          schema: @series_type + '_tsv',
          schema_metadata: nil,
      }

      time_series = StudyResult::TimeSeries.where(time_series_params).first_or_initialize

      append_text = @data.map do |row|
        WEBGAZER_HEADERS.map{|col| row[col]}.join("\t")
      end.join("\n")

      if !time_series.file.file
        time_series.file = FileIO.new(WEBGAZER_HEADERS.map(&:to_s).join("\t") + "\n" + append_text + "\n", 'webgazer.tsv')
        logger.info "Creating initial time series with #{@data.length} rows to #{time_series.file.path}"
      else
        unless File.exists? time_series.file.path
          logger.warn "Time Series file doesn't exist: #{time_series.file.path}"
          dir = File.dirname(time_series.file.path)
          FileUtils.mkdir_p dir
          File.open(time_series.file.path, 'w') { |file| file.write(WEBGAZER_HEADERS.map(&:to_s).join("\t") + "\n") }
        end
        open(time_series.file.path, 'a') do |f|
          f.puts append_text
        end
        logger.info "Wrote #{@data.length} rows to #{time_series.file.path}"
      end

      unless time_series.save
        logger.error 'time series failed to save!'
        logger.error time_series_params.ai
        logger.error time_series.ai
        logger.error time_series.errors.full_messages.join("\n")
      end

      logger.info "Saved time series #{time_series.id}"

      respond_to do |format|
        format.xml { render :xml => '', status: :created }
        format.json { render :json => @response.to_json, status: :created }
      end
    end

    private

    def respond_error(msg, status = :unprocessable_entity)
      @response = ChaosResponse.new([], msg)
      respond_to do |format|
        format.xml { render :xml => @response.to_xml, status: status }
        format.json { render :json => @response.to_json, status: status }
      end
    end


    def post_params
      #validate POST parameters
      params.permit(:format, :sessionGUID, :series_type, points: WEBGAZER_HEADERS)
    end
  end
end
