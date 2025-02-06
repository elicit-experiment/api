# frozen_string_literal: true

class FileIO < StringIO
  def initialize(stream, filename)
    super(stream)
    @original_filename = filename
  end

  attr_reader :original_filename
end

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

    has_one_attached :in_progress_file, service: :local
    has_one_attached :finalized_file

    scope :has_finalized_file, -> { joins(finalized_file_attachment: :blob) }
    scope :has_in_progress_file, -> { joins(in_progress_file_attachment: :blob) }

    scope :has_no_finalized_file, -> { left_outer_joins(:finalized_file_attachment).where(active_storage_attachments: { id: nil }) }

    scope :ready_for_finalization, -> { has_no_finalized_file.where(Arel.sql("updated_at < current_timestamp - interval '1 hour'")) }

    SERIES_TYPES = %i[webgazer mouse face_landmark].freeze
    FILE_TYPES = %i[tsv json].freeze

    # append ndjson to the file.
    def append(data)
      # self.file is a carrierwave upload, and it won't have a path until it is created. So we buffer to a stringio and set
      # the carrierwave file to that stringio to save.
      stream = if file.path.nil?
                 StringIO.new
               else
                 unless File.exist?(file.path)
                   logger.warn "Time Series file doesn't exist: #{file.path}"
                   dir = File.dirname(file.path)
                   FileUtils.mkdir_p dir
                 end

                 File.open(file.path, 'a')
               end

      datas = if data.is_a? Array
                data
              else
                [data]
              end

      datas.each do |row|
        stream.puts "#{row.to_json}\n"
      end

      self.file = FileIO.new(stream.string, filename) unless file.path
    ensure
      stream.close if stream.present?

      logger.debug "Wrote #{datas.size} rows to #{file.path}"
    end

    def append_raw(data_string)
      file_path = nil
      stream = if in_progress_file.attached?
                 file_path = in_progress_file.service.path_for(in_progress_file.key)
                 unless File.exist?(file_path)
                   logger.warn "Time Series file doesn't exist: #{file_path}"
                   dir = File.dirname(file_path)
                   FileUtils.mkdir_p dir
                 end

                 File.open(file_path, 'a')
               else
                 StringIO.new
               end

      stream << data_string
      stream << "\n"

      unless in_progress_file.attached?
        logger.debug 'Creating in progress file attachment'
        # This is asynchronous:
        # in_progress_file.attach(io: StringIO.new(stream.string), filename: filename, content_type: 'application/json')
        # self.send(:in_progress_file).analyze

        # For testing and simplicity in production, we use the synchronous method here https://stackoverflow.com/questions/61309182/how-to-force-activestorageattachedattach-to-run-synchronously-disable-asyn
        blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new(stream.string), filename: filename, service_name: :local, content_type: 'application/json'
        )
        blob.analyze
        attached = send(:in_progress_file)
        attached.attach(blob)

        file_path = in_progress_file.service.path_for(in_progress_file.key)
      end
    ensure
      stream.close if stream.present?

      logger.debug "Wrote #{data_string.size} bytes to #{file_path}"
    end

    def append_to_tsv(append_text, headers)
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
        File.open(self.file.path, 'a') do |f|
          f.puts append_text
        end
        logger.debug "Wrote #{rows} rows to #{self.file.path}"
      end
    end

    def append_file_to_tsv(append_file, headers)
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
      return nil if schema.blank?

      schema.split('_')[0..-2].join('_')
    end

    def file_type
      return nil if schema.blank?

      schema.split('_').last
    end

    def in_progress_file_path
      in_progress_file.attached? ? in_progress_file.service.path_for(in_progress_file.key) : file.path
    end

    def in_progress_file_url
      if in_progress_file.attached?
        Rails.application.routes.url_helpers.rails_blob_url(in_progress_file)
      elsif file
        Rails.application.routes.url_helpers.api_v1_study_result_time_series_content_url(time_series_id: id,
                                                                                         study_result_id: stage.experiment.study_result_id)
      end
    end

    def finalize(force: false)
      return false unless force || finalizable?

      in_progress_file_path = (in_progress_file.attached? ? in_progress_file.service.path_for(in_progress_file.key) : nil) || file&.path
      raise "No in progress file path: '#{in_progress_file_path}'" unless in_progress_file_path && File.exist?(in_progress_file_path)

      logger.info "Finalizing time series #{id} with #{in_progress_file_path}"

      # Create a StringIO object to hold the gzipped data in memory
      gzip_io = StringIO.new(+'', 'r+b')

      # Use a GzipWriter to compress the file content into the StringIO object
      Zlib::GzipWriter.wrap(gzip_io) do |gz|
        File.open(in_progress_file_path, 'rb') do |file|
          # Stream-read the file in chunks to minimize memory usage
          while (chunk = file.read(4096))
            gz.write(chunk)
          end
        end
      end

      gzip_io.close_write

      # Sync version:
      #
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(gzip_io.string, 'r'),
        filename: "time_series_#{id}.#{filename}.gz",
        content_type: 'application/gzip'
      )
      blob.analyze
      attached = send(:finalized_file)
      attached.attach(blob)

      # This works async:
      #
      # finalized_file.attach(io: StringIO.new(gzip_io.string, 'r'),
      #                       filename: "time_series_#{id}.#{file_type}.gz",
      #                       content_type: 'application/gzip')

      logger.info "Created final file for time series #{id} #{gzip_io.string.size} bytes"

      # Clean up the in-progress files
      purge_in_progress_files!

      logger.info "Finalized time series #{id}"
    rescue StandardError => e
      logger.error "Failed to finalize time series #{id} #{e.class.name} #{e.message}"
    ensure
      gzip_io&.close
    end

    def finalizable?
      return false if finalized_file.attached?
      return false unless in_progress_file.attached? || file&.file&.exists?

      updated_at < 1.hour.ago
    end

    def file_url
      finalized_file.attached? ? signed_finalized_url : in_progress_file_url
    end

    def signed_finalized_url
      require 'aws-sdk-s3'

      # The ActiveStorage default urls don't seem to work with Digital Ocean Spaces. They result in Bad Gateway, possibly
      # due to the addition of attachment/download and other query parameter pieces.
      s3 = Aws::S3::Client.new(
        endpoint: 'https://nyc3.digitaloceanspaces.com',
        region: 'nyc3',
        access_key_id: ENV.fetch('AWS_ACCESS_ID'),
        secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
      )

      signer = Aws::S3::Presigner.new(client: s3)
      signer.presigned_url(:get_object, bucket: Rails.env.production? ? 'elicit' : 'elicit-dev', key: finalized_file.key)
    end

    private

    def purge_in_progress_files!
      in_progress_file.purge
    end
  end
end
