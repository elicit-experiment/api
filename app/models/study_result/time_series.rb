# frozen_string_literal: true

module StudyResult
  def self.table_name_prefix
    'study_result_'
  end

  class TimeSeries < ApplicationRecord
    belongs_to :stage, class_name: 'Stage', foreign_key: 'stage_id'
    belongs_to :study_definition, class_name: 'StudyDefinition', foreign_key: 'study_definition_id'
    belongs_to :protocol_definition, class_name: 'ProtocolDefinition', foreign_key: 'protocol_definition_id'
    belongs_to :phase_definition, class_name: 'PhaseDefinition', foreign_key: 'phase_definition_id'
    belongs_to :component, class_name: 'Component', foreign_key: 'component_id', optional: true

    mount_uploader :file, TimeSeriesUploader

    def append_to_tsv(append_text, headers, filename)
      rows = append_text.split("\n").size
      if !file.file
        self.file = FileIO.new(headers.map(&:to_s).join("\t") + "\n" + append_text + "\n", filename)
        logger.info "Creating initial time series with #{rows} rows to #{file.path}"
      else
        unless File.exist? file.path
          logger.warn "Time Series file doesn't exist: #{file.path}"
          dir = File.dirname(file.path)
          FileUtils.mkdir_p dir
          File.open(file.path, 'w') { |file| file.write(headers.map(&:to_s).join("\t") + "\n") }
        end
        open(self.file.path, 'a') do |f|
          f.puts append_text
        end
        logger.debug "Wrote #{rows} rows to #{self.file.path}"
      end
    end

    def append_file_to_tsv(append_file, headers, filename)
      unless file.file
        self.file = FileIO.new(headers.map(&:to_s).join("\t") + "\n", filename)
        logger.info "Creating initial time series with header to #{file.path}"
        save!
      end

      filepath = file.path

      unless File.exist? filepath
        logger.warn "Time Series file doesn't exist: #{filepath}"
        dir = File.dirname(filepath)
        FileUtils.mkdir_p dir
        File.open(filepath, 'w') do |file|
          file.write(headers.map(&:to_s).join("\t") + "\n")
        end
      end

      blocks = 0
      File.open(filepath, 'a') do |outfile|
        while buffer = append_file.read(4096)
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
  end
end
