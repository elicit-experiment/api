# frozen_string_literal: true

require 'test_helper'
require 'uri'

class DemoStorageTest < ActionDispatch::IntegrationTest
  test 'a finalized time series can be downloaded using local storage without AWS credentials' do
    series = study_result_time_series(:json_facelandmarker_time_series_1)
    series.finalized_file.attach(io: StringIO.new('demo measurement'), filename: 'demo.json.gz',
                                 content_type: 'application/gzip')

    url = series.signed_finalized_url
    assert_includes url, '/rails/active_storage/blobs/redirect/'
    assert_not_includes url, 'digitaloceanspaces.com'
    get URI(url).request_uri
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'demo measurement', response.body
  end

  test 'demo contact submissions do not call the external email service' do
    previous = ENV['ELICIT_DEMO']
    ENV['ELICIT_DEMO'] = 'true'
    RestClient.expects(:post).never
    ContactMailer.send_contact_email({})
  ensure
    previous.nil? ? ENV.delete('ELICIT_DEMO') : ENV['ELICIT_DEMO'] = previous
  end
end
