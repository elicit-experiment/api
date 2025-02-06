require 'test_helper'
require 'minitest/unit'
require 'minitest/mock'
require 'fakefs/safe'

module StudyResult
  class TimeSeriesTest < ActiveSupport::TestCase
    test 'face_landmark json single row' do
      time_series = study_result_time_series(:json_facelandmarker_time_series_1)

      time_series.append([{test: 'this'}])
      time_series.save!
      time_series.reload

      assert_equal(File.extname(time_series.file.path), '.json')
      assert_equal File.read(time_series.file.path).strip, { test: 'this' }.to_json
    end

    test 'face_landmark json multiple rows' do
      time_series = study_result_time_series(:json_facelandmarker_time_series_1)

      rows = [
        {test: 'this'},
        {test: 'that'},
        {test: 'the other'}
      ]

      time_series.append(rows)
      time_series.save!
      time_series.append(rows)
      time_series.save!
      time_series.reload

      assert_equal(File.extname(time_series.file.path), '.json')
      assert_equal File.read(time_series.file.path).strip, rows.concat(rows).map(&:to_json).join("\n")
    end

    test 'mouse tsv single append' do
      time_series = study_result_time_series(:learning_mouse_time_series_1)

      rows = [[1,2,10.seconds.ago.to_i], [3,4,10.seconds.ago.to_i]]
      headers = %w[x y timeStamp]

      tsv_content = rows.map { |row| row.map(&:to_s).join("\t") }

      time_series.append_to_tsv(tsv_content.join("\n"), headers)
      time_series.save!
      time_series.reload

      assert_equal(File.extname(time_series.file.path), '.tsv')
      assert_equal [headers.join("\t"), tsv_content].join("\n"), File.read(time_series.file.path).strip
    end

    test 'mouse tsv multiple append' do
      time_series = study_result_time_series(:learning_mouse_time_series_1)

      rows = [[1,2,10.seconds.ago.to_i], [3,4,10.seconds.ago.to_i]]
      headers = %w[x y timeStamp]

      tsv_content = rows.map { |row| row.map(&:to_s).join("\t") }

      time_series.append_to_tsv(tsv_content.join("\n"), headers)
      time_series.save!
      time_series.append_to_tsv(tsv_content.join("\n"), headers)
      time_series.save!
      time_series.reload

      assert_equal(File.extname(time_series.file.path), '.tsv')
      assert_equal [headers.join("\t"), tsv_content, tsv_content].join("\n"), File.read(time_series.file.path).strip
    end
  end
end


