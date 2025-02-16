require 'test_helper'
require 'minitest/unit'
require 'minitest/mock'
require 'fakefs/safe'

module StudyResult
  class TimeSeriesTest < ActiveSupport::TestCase
    test 'face_landmark json single row' do
      time_series = study_result_time_series(:json_facelandmarker_time_series_1)

      time_series.append_data([{test: 'this'}])
      time_series.save!
      time_series.reload

      assert_equal File.read(time_series.in_progress_file_path).strip, { test: 'this' }.to_json
    end

    test 'face_landmark json multiple rows' do
      time_series = study_result_time_series(:json_facelandmarker_time_series_1)

      rows = [
        {test: 'this'},
        {test: 'that'},
        {test: 'the other'}
      ]

      time_series.append_data(rows)
      time_series.save!
      time_series.append_data(rows)
      time_series.save!
      time_series.reload

      assert_equal File.read(time_series.in_progress_file_path).strip, rows.concat(rows).map(&:to_json).join("\n")
    end

    test '#append_raw face_landmark json multiple rows' do
      time_series = study_result_time_series(:json_facelandmarker_time_series_1)

      rows = [
        {test: 'this'},
        {test: 'that'},
        {test: 'the other'}
      ]

      2.times.each do
        time_series.append_raw(rows.map(&:to_json).join("\n") + "\n")
        time_series.save!
      end

      expected_content = rows.concat(rows).map(&:to_json).join("\n")
      assert_equal expected_content, File.read(TimeSeries.find(time_series.id).in_progress_file_path).strip
    end

    test 'mouse tsv single append' do
      time_series = study_result_time_series(:learning_mouse_time_series_1)

      rows = [[1,2,10.seconds.ago.to_i], [3,4,10.seconds.ago.to_i]]
      headers = %w[x y timeStamp]

      tsv_content = rows.map { |row| row.map(&:to_s).join("\t") }

      time_series.append_string_to_tsv(tsv_content.join("\n"), headers)
      time_series.save!

      expected_content = [headers.join("\t"), tsv_content].join("\n")
      assert_equal(time_series.in_progress_file.attached?, true)
      assert_equal expected_content, File.read(time_series.in_progress_file_path).strip
    end

    test 'mouse tsv single file append' do
      time_series = study_result_time_series(:learning_mouse_time_series_1)

      rows = [[1,2,10.seconds.ago.to_i], [3,4,10.seconds.ago.to_i]]
      headers = %w[x y timeStamp]

      tsv_content = rows.map { |row| row.map(&:to_s).join("\t") }.join("\n")
      Tempfile.open('test') do |file|
        file.write tsv_content
        file.rewind

        time_series.append_file_to_tsv(file, headers)
        time_series.save!
      end

      expected_content = [headers.join("\t"), tsv_content].join("\n")
      assert_equal(time_series.in_progress_file.attached?, true)
      assert_equal expected_content, File.read(time_series.in_progress_file_path).strip
    end

    test 'mouse tsv multiple append' do
      time_series = study_result_time_series(:learning_mouse_time_series_1)

      rows = [[1,2,10.seconds.ago.to_i], [3,4,10.seconds.ago.to_i]]
      headers = %w[x y timeStamp]

      tsv_content = rows.map { |row| row.map(&:to_s).join("\t") }

      time_series.append_string_to_tsv(tsv_content.join("\n"), headers)
      time_series.save!
      time_series.append_string_to_tsv(tsv_content.join("\n"), headers)
      time_series.save!
      time_series.reload

      expected_content = [headers.join("\t"), tsv_content.join("\n"), tsv_content.join("\n")].join("\n")
      assert_equal(time_series.in_progress_file.attached?, true)
      assert_equal expected_content, File.read(time_series.in_progress_file_path).strip
    end
  end
end


