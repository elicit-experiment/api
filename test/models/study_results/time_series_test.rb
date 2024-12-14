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
  end
end


