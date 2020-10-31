# frozen_string_literal: true

class AddIndices < ActiveRecord::Migration[5.1]
  def change
    add_index :chaos_sessions, :user_id
    add_index :chaos_sessions, :study_definition_id
    add_index :chaos_sessions, :protocol_definition_id
    add_index :chaos_sessions, :phase_definition_id
    add_index :chaos_sessions, :trial_definition_id
    add_index :chaos_sessions, :protocol_user_id
    add_index :chaos_sessions, :study_result_id
    add_index :chaos_sessions, :experiment_id
    add_index :chaos_sessions, :stage_id
    add_index :chaos_sessions, :trial_result_id
    add_index :oauth_access_grants, :resource_owner_id
    add_index :study_result_data_points, :stage_id
    add_index :study_result_experiments, :study_result_id
    add_index :study_result_experiments, :current_stage_id
    add_index :study_result_stages, :experiment_id
    add_index :study_result_stages, :context_id
    add_index :study_result_time_series, :stage_id
    add_index :study_result_trial_results, :experiment_id

    add_index :study_definitions, :allow_anonymous_users
    add_index :study_definitions, :show_in_study_list
  end
end
