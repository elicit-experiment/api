# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181218035443) do

  create_table "chaos_sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "session_guid", null: false
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.integer "phase_definition_id"
    t.integer "trial_definition_id"
    t.integer "protocol_user_id"
    t.integer "study_result_id"
    t.integer "experiment_id"
    t.integer "stage_id"
    t.integer "trial_result_id"
    t.boolean "preview"
    t.string "url", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["experiment_id"], name: "index_chaos_sessions_on_experiment_id"
    t.index ["phase_definition_id"], name: "index_chaos_sessions_on_phase_definition_id"
    t.index ["protocol_definition_id"], name: "index_chaos_sessions_on_protocol_definition_id"
    t.index ["protocol_user_id"], name: "index_chaos_sessions_on_protocol_user_id"
    t.index ["stage_id"], name: "index_chaos_sessions_on_stage_id"
    t.index ["study_definition_id"], name: "index_chaos_sessions_on_study_definition_id"
    t.index ["study_result_id"], name: "index_chaos_sessions_on_study_result_id"
    t.index ["trial_definition_id"], name: "index_chaos_sessions_on_trial_definition_id"
    t.index ["trial_result_id"], name: "index_chaos_sessions_on_trial_result_id"
    t.index ["user_id"], name: "index_chaos_sessions_on_user_id"
  end

  create_table "components", force: :cascade do |t|
    t.string "definition_data"
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.integer "phase_definition_id", null: false
    t.integer "trial_definition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phase_definition_id"], name: "index_components_on_phase_definition_id"
    t.index ["protocol_definition_id"], name: "index_components_on_protocol_definition_id"
    t.index ["study_definition_id"], name: "index_components_on_study_definition_id"
    t.index ["trial_definition_id"], name: "index_components_on_trial_definition_id"
  end

  create_table "media_files", force: :cascade do |t|
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "phase_definitions", force: :cascade do |t|
    t.string "definition_data"
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "trial_ordering"
    t.index ["protocol_definition_id"], name: "index_phase_definitions_on_protocol_definition_id"
    t.index ["study_definition_id"], name: "index_phase_definitions_on_study_definition_id"
  end

  create_table "phase_orders", force: :cascade do |t|
    t.string "sequence_data"
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["protocol_definition_id"], name: "index_phase_orders_on_protocol_definition_id"
    t.index ["study_definition_id"], name: "index_phase_orders_on_study_definition_id"
    t.index ["user_id"], name: "index_phase_orders_on_user_id"
  end

  create_table "protocol_definitions", force: :cascade do |t|
    t.string "name"
    t.integer "version"
    t.string "type"
    t.string "summary"
    t.string "description"
    t.string "definition_data"
    t.boolean "active", default: false, null: false
    t.integer "study_definition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["study_definition_id"], name: "index_protocol_definitions_on_study_definition_id"
  end

  create_table "protocol_users", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "protocol_definition_id", null: false
    t.string "group_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_name"], name: "index_protocol_users_on_group_name"
    t.index ["protocol_definition_id"], name: "index_protocol_users_on_protocol_definition_id"
    t.index ["user_id"], name: "index_protocol_users_on_user_id"
  end

  create_table "stimuli", force: :cascade do |t|
    t.string "definition_data"
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.integer "phase_definition_id", null: false
    t.integer "trial_definition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phase_definition_id"], name: "index_stimuli_on_phase_definition_id"
    t.index ["protocol_definition_id"], name: "index_stimuli_on_protocol_definition_id"
    t.index ["study_definition_id"], name: "index_stimuli_on_study_definition_id"
    t.index ["trial_definition_id"], name: "index_stimuli_on_trial_definition_id"
  end

  create_table "study_definitions", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.integer "principal_investigator_user_id", null: false
    t.integer "version"
    t.text "data"
    t.integer "lock_question"
    t.integer "enable_previous"
    t.integer "no_of_trials"
    t.integer "trials_completed"
    t.text "footer_label"
    t.string "redirect_close_on_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "AllowAnonymousUsers"
    t.boolean "ShowInStudyList"
    t.boolean "allow_anonymous_users"
    t.boolean "show_in_study_list"
    t.integer "max_anonymous_users"
    t.index ["allow_anonymous_users"], name: "index_study_definitions_on_allow_anonymous_users"
    t.index ["principal_investigator_user_id"], name: "index_study_definitions_on_principal_investigator_user_id"
    t.index ["show_in_study_list"], name: "index_study_definitions_on_show_in_study_list"
  end

  create_table "study_result_contexts", force: :cascade do |t|
    t.datetime "datetime"
    t.text "context_type"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_result_data_points", force: :cascade do |t|
    t.integer "stage_id", null: false
    t.integer "protocol_user_id"
    t.integer "phase_definition_id"
    t.integer "trial_definition_id"
    t.integer "component_id"
    t.string "kind"
    t.string "point_type"
    t.string "value"
    t.string "method"
    t.datetime "datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_study_result_data_points_on_component_id"
    t.index ["phase_definition_id"], name: "index_study_result_data_points_on_phase_definition_id"
    t.index ["protocol_user_id"], name: "index_study_result_data_points_on_protocol_user_id"
    t.index ["stage_id"], name: "index_study_result_data_points_on_stage_id"
    t.index ["trial_definition_id"], name: "index_study_result_data_points_on_trial_definition_id"
  end

  create_table "study_result_experiments", force: :cascade do |t|
    t.integer "study_result_id", null: false
    t.integer "protocol_user_id", null: false
    t.integer "current_stage_id"
    t.integer "num_stages_completed"
    t.integer "num_stages_remaining"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.index ["current_stage_id"], name: "index_study_result_experiments_on_current_stage_id"
    t.index ["protocol_user_id"], name: "index_study_result_experiments_on_protocol_user_id"
    t.index ["study_result_id"], name: "index_study_result_experiments_on_study_result_id"
  end

  create_table "study_result_stages", force: :cascade do |t|
    t.integer "experiment_id", null: false
    t.integer "protocol_user_id", null: false
    t.integer "phase_definition_id", null: false
    t.integer "last_completed_trial"
    t.integer "current_trial"
    t.integer "num_trials"
    t.integer "context_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.index ["context_id"], name: "index_study_result_stages_on_context_id"
    t.index ["experiment_id"], name: "index_study_result_stages_on_experiment_id"
    t.index ["phase_definition_id"], name: "index_study_result_stages_on_phase_definition_id"
    t.index ["protocol_user_id"], name: "index_study_result_stages_on_protocol_user_id"
  end

  create_table "study_result_study_results", force: :cascade do |t|
    t.integer "study_definition_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.index ["study_definition_id"], name: "index_study_result_study_results_on_study_definition_id"
    t.index ["user_id"], name: "index_study_result_study_results_on_user_id"
  end

  create_table "study_result_time_series", force: :cascade do |t|
    t.integer "stage_id"
    t.integer "study_definition_id"
    t.integer "protocol_definition_id"
    t.integer "phase_definition_id"
    t.integer "component_id"
    t.string "file"
    t.string "schema"
    t.string "schema_metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_study_result_time_series_on_component_id"
    t.index ["phase_definition_id"], name: "index_study_result_time_series_on_phase_definition_id"
    t.index ["protocol_definition_id"], name: "index_study_result_time_series_on_protocol_definition_id"
    t.index ["stage_id"], name: "index_study_result_time_series_on_stage_id"
    t.index ["study_definition_id"], name: "index_study_result_time_series_on_study_definition_id"
  end

  create_table "study_result_trial_results", force: :cascade do |t|
    t.integer "experiment_id", null: false
    t.integer "protocol_user_id", null: false
    t.integer "phase_definition_id", null: false
    t.integer "trial_definition_id", null: false
    t.string "session_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.index ["experiment_id"], name: "index_study_result_trial_results_on_experiment_id"
    t.index ["phase_definition_id"], name: "index_study_result_trial_results_on_phase_definition_id"
    t.index ["protocol_user_id"], name: "index_study_result_trial_results_on_protocol_user_id"
    t.index ["trial_definition_id"], name: "index_study_result_trial_results_on_trial_definition_id"
  end

  create_table "trial_definitions", force: :cascade do |t|
    t.string "definition_data"
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.integer "phase_definition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phase_definition_id"], name: "index_trial_definitions_on_phase_definition_id"
    t.index ["protocol_definition_id"], name: "index_trial_definitions_on_protocol_definition_id"
    t.index ["study_definition_id"], name: "index_trial_definitions_on_study_definition_id"
  end

  create_table "trial_order_selection_mappings", force: :cascade do |t|
    t.integer "trial_order_id"
    t.integer "user_id"
    t.integer "phase_definition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phase_definition_id"], name: "index_trial_order_selection_mappings_on_phase_definition_id"
    t.index ["trial_order_id"], name: "index_trial_order_selection_mappings_on_trial_order_id"
    t.index ["user_id"], name: "index_trial_order_selection_mappings_on_user_id"
  end

  create_table "trial_orders", force: :cascade do |t|
    t.string "sequence_data"
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.integer "phase_definition_id", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phase_definition_id"], name: "index_trial_orders_on_phase_definition_id"
    t.index ["protocol_definition_id"], name: "index_trial_orders_on_protocol_definition_id"
    t.index ["study_definition_id"], name: "index_trial_orders_on_study_definition_id"
    t.index ["user_id"], name: "index_trial_orders_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "anonymous"
    t.string "role"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
