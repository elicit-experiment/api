# frozen_string_literal: true

require 'test_helper'
require 'minitest/unit'

require 'zlib'
require 'digest'

def md5_of_gzipped_file(gzip_path)
  begin
    md5 = Digest::MD5.new
    gz_file = File.open(gzip_path, 'rb')
    gz = Zlib::GzipReader.new(gz_file)

    begin
      while (chunk = gz.read(4096)) # Read in chunks
        md5.update(chunk)
      end
    rescue Zlib::GzipFile::Error => e
      puts "Error reading gzip file: #{e.message}"
      return nil # Or handle the error as appropriate
    ensure
      gz.close unless gz.nil?
      gz_file.close unless gz_file.nil?
    end

    md5.hexdigest
  rescue Errno::ENOENT
    puts "Error: File not found at #{gzip_path}"
    return nil
  rescue StandardError => e
    puts "An unexpected error occurred: #{e.message}"
    puts e.backtrace
    return nil
  end
end

def md5_of_file(path)
  begin
    md5 = Digest::MD5.new
    file = File.open(path, 'rb')

    begin
      while (chunk = file.read(4096)) # Read in chunks
        md5.update(chunk)
      end
    rescue Zlib::GzipFile::Error => e
      puts "Error reading gzip file: #{e.message}"
      return nil # Or handle the error as appropriate
    ensure
      file.close unless file.nil?
    end

    md5.hexdigest
  rescue Errno::ENOENT
    puts "Error: File not found at #{path}"
    return nil
  rescue StandardError => e
    puts "An unexpected error occurred: #{e.message}"
    puts e.backtrace
    return nil
  end
end

class FinalizeTimeseriesCommandTest < ActionDispatch::IntegrationTest

  test 'serialize gzip to finalized file (old in-progress)' do
    # Setup time series with Carrier wave in progress file
    @time_series = study_result_time_series(:json_facelandmarker_time_series_1)
    @time_series.created_at = @time_series.updated_at = 2.hours.ago
    @time_series.file = fixture_file_upload('face_landmark_1.json', 'application/ndjson')
    @time_series.save!

    original_md5 = md5_of_file @time_series.file.path

    # Validate finalization query
    assert(StudyResult::TimeSeries.ready_for_finalization.size == 1)
    assert(StudyResult::TimeSeries.ready_for_finalization.first.id == @time_series.id)

    # Run command
    result = FinalizeTimeseriesCommand.new(time_series_relation: StudyResult::TimeSeries.ready_for_finalization).execute

    # Validate that it finalized the right time series
    updated_time_series = result[:updated_time_series]
    assert(updated_time_series.size == 1)
    assert(updated_time_series.first.id == @time_series.id)
    assert(@time_series.reload.finalized_file.attached?)

    # Validate that it uploaded the correct gziped json file.
    gzip_path = @time_series.finalized_file.service.path_for(@time_series.finalized_file.key)
    finalized_md5 = md5_of_gzipped_file(gzip_path)
    assert_equal original_md5, finalized_md5
  end

  test 'serialize gzip to finalized file (new in-progress)' do
    # Setup time series with ActionStorage in progress file (included in the fixture definition)
    @time_series = study_result_time_series(:json_facelandmarker_time_series_2)
    @time_series.created_at = @time_series.updated_at = 2.hours.ago
    @time_series.save!

    assert(@time_series.in_progress_file.attached?)
    assert(@time_series.finalizable?)

    # Check finalization query
    assert(StudyResult::TimeSeries.ready_for_finalization.size == 1)
    assert(StudyResult::TimeSeries.ready_for_finalization.first.id == @time_series.id)

    # Run the command
    result = FinalizeTimeseriesCommand.new(time_series_relation: StudyResult::TimeSeries.ready_for_finalization).execute

    # Validate that it finalized the right time series
    updated_time_series = result[:updated_time_series]
    assert(updated_time_series.size == 1)
    assert(updated_time_series.first.id == @time_series.id)

    assert(@time_series.reload.finalized_file.attached?)

    # Validate that it uploaded the correct gziped json file.
    gzip_path = @time_series.finalized_file.service.path_for(@time_series.finalized_file.key)

    finalized_md5 = md5_of_gzipped_file(gzip_path)
    original_md5 = md5_of_file Rails.root.join('test/fixtures/files/face_landmark_1.json')
    assert_equal original_md5, finalized_md5
  end
end
