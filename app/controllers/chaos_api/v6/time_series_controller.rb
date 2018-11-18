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
          study_definition_id: @chaos_session.study_definition_id,
          protocol_definition_id: @chaos_session.protocol_definition_id,
          phase_definition_id: @chaos_session.phase_definition_id,
          schema: @series_type + '_tsv',
          schema_metadata: nil,
      }

      time_series = StudyResult::TimeSeries.first_or_initialize(time_series_params) do |ts|
      #  ts.save!
      end

      append_text = @data.map do |row|
        WEBGAZER_HEADERS.map{|col| row[col]}.join("\t")
      end.join("\n")

      if !time_series.file.file
        time_series.file = FileIO.new(WEBGAZER_HEADERS.map(&:to_s).join("\t") + "\n" + append_text + "\n", 'webgazer.tsv')
      else
        open(time_series.file.path, 'a') do |f|
          f.puts append_text
        end
      end

      time_series.save!

      respond_to do |format|
        format.xml { render :xml => '' }
        format.json { render :json => @response.to_json }
      end
    end

    private

    def post_params
      #validate POST parameters
      params.permit(:format, :sessionGUID, :series_type, points: WEBGAZER_HEADERS)
    end
  end
end
