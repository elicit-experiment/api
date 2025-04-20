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

    class << self
      def schema_for(series_type:, format:)
        case series_type
        when :face_landmark
          return nil unless %i[json msgpack].include?(format)
        when :mouse
          return nil unless format == :tsv
        else
          return nil
        end

        "#{series_type}_#{format}"
      end
    end

    def file_content_type
      return nil if schema.blank?

      Mime::Type.lookup_by_extension(file_type.to_sym).to_s
    end

    # append ndjson to the file.
    def append_data(data)
      append_raw("#{data.map(&:to_json).join("\n")}\n")
    end

    def append(_data)
      raise 'Deprecated'
    end

    def append_raw(data_string)
      _file_path, stream = in_progress_stream

      stream << data_string

      file_field = :in_progress_file

      file_path = ensure_attached(stream, file_field, file_content_type)
    ensure
      stream.close if stream.present?

      logger.debug "Wrote #{data_string.size} bytes to #{file_path}"
    end

    def append_string_to_tsv(append_text, headers)
      append_to_tsv(headers) do |stream|
        stream << append_text
        stream << "\n"
        append_text.size + 1
      end
    end

    def append_to_tsv(headers)
      file_path, stream = in_progress_stream
      characters_written = 0

      # if the file_path doesn't exist, the file is new, and we need to add the header
      if file_path.blank?
        header_string = "#{headers.join("\t")}\n"
        stream << header_string
        characters_written = header_string.size
      end

      characters_written += yield stream

      file_path = ensure_attached(stream, :in_progress_file, file_content_type)
    ensure
      stream.close if stream.present?

      logger.debug "Wrote #{characters_written} bytes to #{file_path}"
    end

    def append_file_to_tsv(append_file, headers)
      append_to_tsv(headers) do |stream|
        blocks = 0
        characters_written = 0
        while (buffer = append_file.read(4096))
          stream << buffer
          characters_written += buffer.size
          blocks += 1
        end

        logger.debug "Wrote #{blocks} blocks from input file"

        characters_written
      end
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

    def validate_in_progress_file
      if in_progress_file.attached?
        file_path = in_progress_file.service.path_for(in_progress_file.key)
        unless File.exist?(file_path)
          logger.warn "Time Series file doesn't exist: #{file_path}"
          errors.add(:in_progress_file, "File doesn't exist: #{file_path}")
        end

        File.foreach(file_path).with_index do |line, index|
          if line.strip.empty?
            logger.warn "Empty line at #{index + 1}: #{line}"
            errors.add(:in_progress_file, "Invalid JSON line format at line #{index + 1}")

          end
          unless line.start_with?('{') && line.strip.end_with?('}')
            logger.warn "Invalid JSON line format at line #{index + 1}: #{line}"
            errors.add(:in_progress_file, "Invalid JSON line format at line #{index + 1}")
          end
        end
      end
    end

    private

    def ensure_attached(stream, file_field, content_type)
      unless public_send(file_field).attached?
        logger.debug 'Creating in progress file attachment'
        # This is asynchronous:
        # in_progress_file.attach(io: StringIO.new(stream.string), filename: filename, content_type: 'application/json')
        # self.send(:in_progress_file).analyze

        # For testing and simplicity in production, we use the synchronous method here https://stackoverflow.com/questions/61309182/how-to-force-activestorageattachedattach-to-run-synchronously-disable-asyn
        blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new(stream.string), filename: filename, service_name: :local, content_type: content_type
        )
        blob.analyze
        attached = public_send(file_field)
        attached.attach(blob)

        file_path = public_send(file_field).service.path_for(in_progress_file.key)
      end
      file_path
    end

    # return the stream and filename (if it exists yet) for the in-progress file
    def in_progress_stream(mode = 'ab')
      stream = if in_progress_file.attached?
                 file_path = in_progress_file.service.path_for(in_progress_file.key)
                 unless File.exist?(file_path)
                   logger.warn "Time Series file doesn't exist: #{file_path}"
                   dir = File.dirname(file_path)
                   FileUtils.mkdir_p dir
                 end

                 File.open(file_path, mode)
               else
                 StringIO.new
               end

      [file_path, stream]
    end

    def purge_in_progress_files!
      logger.info "Finalized time series #{id}"
      file&.remove!
      in_progress_file.purge
      save! if changed?
    end
  end
end
