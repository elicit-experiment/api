# frozen_string_literal: true

module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class TimeSeries < ApplicationRecord
    belongs_to :stage, class_name: 'StudyResult::Stage'
    belongs_to :study_definition, class_name: 'StudyDefinition'
    belongs_to :protocol_definition, class_name: 'ProtocolDefinition'
    belongs_to :phase_definition, class_name: 'PhaseDefinition'
    belongs_to :component, class_name: 'Component', optional: true

    mount_uploader :file, TimeSeriesUploader

    SERIES_TYPES = %i[webgazer mouse face_landmark].freeze
    FILE_TYPES = %i[tsv json]

    # append ndjson to the file.
    def append(data)
      stream = if file.path.nil?
                 StringIO.new
               else
                 unless File.exist?(file.path)
                   logger.warn "Time Series file doesn't exist: #{file.path}"
                   dir = File.dirname(file.path)
                   FileUtils.mkdir_p dir
                 end

                 open(self.file.path, 'a')
               end

      datas = if data.is_a? Array
                data
              else
                [data]
              end

      datas.each do |row|
        stream.puts "#{row.to_json}\n"
      end

      unless file.path
        self.file = FileIO.new(stream.string, filename)
      end
    ensure
      stream.close if stream.present?

      logger.debug "Wrote #{datas.size} rows to #{self.file.path}"
    end


    def append_to_tsv(append_text, headers, filename)
      rows = append_text.split("\n").size
      if !file.file
        self.file = FileIO.new("#{headers.map(&:to_s).join("\t")}\n#{append_text}\n", filename)
        logger.info "Creating initial time series with #{rows} rows to #{file.path}"
      else
        unless File.exist? file.path
          logger.warn "Time Series file doesn't exist: #{file.path}"
          dir = File.dirname(file.path)
          FileUtils.mkdir_p dir
          File.open(file.path, 'w') { |file| file.write("#{headers.map(&:to_s).join("\t")}\n") }
        end
        open(self.file.path, 'a') do |f|
          f.puts append_text
        end
        logger.debug "Wrote #{rows} rows to #{self.file.path}"
      end
    end

    def append_file_to_tsv(append_file, headers, filename)
      unless file.file
        self.file = FileIO.new("#{headers.map(&:to_s).join("\t")}\n", filename)
        logger.info "Creating initial time series with header to #{file.path}"
        save!
      end

      filepath = file.path

      unless File.exist? filepath
        logger.warn "Time Series file doesn't exist: #{filepath}"
        dir = File.dirname(filepath)
        FileUtils.mkdir_p dir
        File.open(filepath, 'w') do |file|
          file.write("#{headers.map(&:to_s).join("\t")}\n")
        end
      end

      blocks = 0
      File.open(filepath, 'a') do |outfile|
        while (buffer = append_file.read(4096))
          outfile << buffer
          blocks += 1
        end
      end

      #      File.open(filepath, 'a') do |outfile|
      #        while (line = append_file.gets)
      #          outfile << line
      #          blocks += 1
      #        end
      #      end

      logger.debug "Wrote #{blocks} blocks from input file to #{filepath}"
    end

    def filename
      "#{series_type}.#{file_type}"
    end

    def series_type
      schema.split('_')[0..-2].join('_')
    end

    def file_type
      schema.split('_').last
    end
  end
end
