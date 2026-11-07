# frozen_string_literal: true

require 'test_helper'

class DatabaseCompatibilityTest < ActiveSupport::TestCase
  test 'generated primary keys and nested JSON survive a save and reload' do
    context = StudyResult::Context.create!(context_type: 'database compatibility')
    assert context.id.positive?
    assert_equal context.id, context.reload.id

    experiment = study_result_experiment(:learning_study_1)
    payload = { 'enabled' => false, 'count' => 0, 'items' => [nil, { 'label' => 'research' }] }
    result = StudyResult::StudyResult.create!(user: user(:subject1), study_definition: study_definition(:learning_study))
    experiment.update!(study_result: result, custom_parameters: payload, client_info: payload)
    assert_equal payload, experiment.reload.custom_parameters
    assert_equal payload, experiment.client_info

    stage = study_result_stage(:learning_study_1)
    stage.update!(client_info: payload)
    assert_equal payload, stage.reload.client_info
  end

  test 'SQLite connections enable foreign keys, WAL and bounded lock waiting' do
    if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      assert_equal 1, ActiveRecord::Base.connection.select_value('PRAGMA foreign_keys')
      assert_equal 'wal', ActiveRecord::Base.connection.select_value('PRAGMA journal_mode')
      assert_equal 5000, ActiveRecord::Base.connection.select_value('PRAGMA busy_timeout')
    else
      assert_equal 'PostgreSQL', ActiveRecord::Base.connection.adapter_name
    end
  end

  test 'finalization uses a qualified timestamp and excludes the exact age boundary' do
    travel_to Time.current.change(usec: 0) do
      series = study_result_time_series(:json_facelandmarker_time_series_2)
      series.update_columns(updated_at: 1.hour.ago)
      assert_not StudyResult::TimeSeries.ready_for_finalization.exists?(id: series.id)
      series.update_columns(updated_at: 1.hour.ago - 1.second)
      assert StudyResult::TimeSeries.ready_for_finalization.exists?(id: series.id)
    end
  end
end
