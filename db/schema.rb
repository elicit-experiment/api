# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_12_28_165522) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "chaos_sessions", id: :serial, force: :cascade do |t|
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
    t.datetime "expires_at", precision: nil, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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

  create_table "components", id: :serial, force: :cascade do |t|
    t.string "definition_data"
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.integer "phase_definition_id", null: false
    t.integer "trial_definition_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.index ["phase_definition_id"], name: "index_components_on_phase_definition_id"
    t.index ["protocol_definition_id"], name: "index_components_on_protocol_definition_id"
    t.index ["study_definition_id"], name: "index_components_on_study_definition_id"
    t.index ["trial_definition_id"], name: "index_components_on_trial_definition_id"
  end

  create_table "media_files", id: :serial, force: :cascade do |t|
    t.string "file"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "phase_definitions", id: :serial, force: :cascade do |t|
    t.string "definition_data"
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "trial_ordering"
    t.index ["protocol_definition_id"], name: "index_phase_definitions_on_protocol_definition_id"
    t.index ["study_definition_id"], name: "index_phase_definitions_on_study_definition_id"
  end

  create_table "phase_orders", id: :serial, force: :cascade do |t|
    t.string "sequence_data"
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["protocol_definition_id"], name: "index_phase_orders_on_protocol_definition_id"
    t.index ["study_definition_id"], name: "index_phase_orders_on_study_definition_id"
    t.index ["user_id"], name: "index_phase_orders_on_user_id"
  end

  create_table "protocol_definitions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "version"
    t.string "type"
    t.string "summary"
    t.string "description"
    t.string "definition_data"
    t.boolean "active", default: false, null: false
    t.integer "study_definition_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["study_definition_id"], name: "index_protocol_definitions_on_study_definition_id"
  end

  create_table "protocol_users", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "protocol_definition_id", null: false
    t.string "group_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["group_name"], name: "index_protocol_users_on_group_name"
    t.index ["protocol_definition_id"], name: "index_protocol_users_on_protocol_definition_id"
    t.index ["user_id"], name: "index_protocol_users_on_user_id"
  end

  create_table "stimuli", id: :serial, force: :cascade do |t|
    t.string "definition_data"
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.integer "phase_definition_id", null: false
    t.integer "trial_definition_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["phase_definition_id"], name: "index_stimuli_on_phase_definition_id"
    t.index ["protocol_definition_id"], name: "index_stimuli_on_protocol_definition_id"
    t.index ["study_definition_id"], name: "index_stimuli_on_study_definition_id"
    t.index ["trial_definition_id"], name: "index_stimuli_on_trial_definition_id"
  end

  create_table "study_definitions", id: :serial, force: :cascade do |t|
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "AllowAnonymousUsers"
    t.boolean "ShowInStudyList"
    t.boolean "allow_anonymous_users"
    t.boolean "show_in_study_list"
    t.integer "max_anonymous_users"
    t.integer "auto_created_user_count", default: 0
    t.integer "max_auto_created_users", default: 0
    t.integer "max_concurrent_users"
    t.index ["allow_anonymous_users"], name: "index_study_definitions_on_allow_anonymous_users"
    t.index ["principal_investigator_user_id"], name: "index_study_definitions_on_principal_investigator_user_id"
    t.index ["show_in_study_list"], name: "index_study_definitions_on_show_in_study_list"
  end

  create_table "study_result_contexts", id: :serial, force: :cascade do |t|
    t.datetime "timestamp", precision: nil
    t.text "context_type"
    t.text "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "study_result_data_points", id: :serial, force: :cascade do |t|
    t.integer "stage_id", null: false
    t.integer "protocol_user_id"
    t.integer "phase_definition_id"
    t.integer "trial_definition_id"
    t.integer "component_id"
    t.string "kind"
    t.string "point_type"
    t.string "value"
    t.string "method"
    t.datetime "datetime", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "entity_type"
    t.boolean "deleted", default: false, null: false
    t.index ["component_id"], name: "index_study_result_data_points_on_component_id"
    t.index ["phase_definition_id"], name: "index_study_result_data_points_on_phase_definition_id"
    t.index ["protocol_user_id"], name: "index_study_result_data_points_on_protocol_user_id"
    t.index ["stage_id"], name: "index_study_result_data_points_on_stage_id"
    t.index ["trial_definition_id"], name: "index_study_result_data_points_on_trial_definition_id"
  end

  create_table "study_result_experiments", id: :serial, force: :cascade do |t|
    t.integer "study_result_id", null: false
    t.integer "protocol_user_id", null: false
    t.integer "current_stage_id"
    t.integer "num_stages_completed"
    t.integer "num_stages_remaining"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.jsonb "custom_parameters"
    t.jsonb "client_info"
    t.index ["current_stage_id"], name: "index_study_result_experiments_on_current_stage_id"
    t.index ["protocol_user_id"], name: "index_study_result_experiments_on_protocol_user_id"
    t.index ["study_result_id"], name: "index_study_result_experiments_on_study_result_id"
  end

  create_table "study_result_stages", id: :serial, force: :cascade do |t|
    t.integer "experiment_id", null: false
    t.integer "protocol_user_id", null: false
    t.integer "phase_definition_id", null: false
    t.integer "last_completed_trial"
    t.integer "current_trial"
    t.integer "num_trials"
    t.integer "context_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.jsonb "client_info"
    t.index ["context_id"], name: "index_study_result_stages_on_context_id"
    t.index ["experiment_id"], name: "index_study_result_stages_on_experiment_id"
    t.index ["phase_definition_id"], name: "index_study_result_stages_on_phase_definition_id"
    t.index ["protocol_user_id"], name: "index_study_result_stages_on_protocol_user_id"
  end

  create_table "study_result_study_results", id: :serial, force: :cascade do |t|
    t.integer "study_definition_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.index ["study_definition_id"], name: "index_study_result_study_results_on_study_definition_id"
    t.index ["user_id"], name: "index_study_result_study_results_on_user_id"
  end

  create_table "study_result_time_series", id: :serial, force: :cascade do |t|
    t.integer "stage_id"
    t.integer "study_definition_id"
    t.integer "protocol_definition_id"
    t.integer "phase_definition_id"
    t.integer "component_id"
    t.string "file"
    t.string "schema"
    t.string "schema_metadata"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["component_id"], name: "index_study_result_time_series_on_component_id"
    t.index ["phase_definition_id"], name: "index_study_result_time_series_on_phase_definition_id"
    t.index ["protocol_definition_id"], name: "index_study_result_time_series_on_protocol_definition_id"
    t.index ["stage_id"], name: "index_study_result_time_series_on_stage_id"
    t.index ["study_definition_id"], name: "index_study_result_time_series_on_study_definition_id"
  end

  create_table "study_result_trial_results", id: :serial, force: :cascade do |t|
    t.integer "experiment_id", null: false
    t.integer "protocol_user_id", null: false
    t.integer "phase_definition_id", null: false
    t.integer "trial_definition_id", null: false
    t.string "session_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.index ["experiment_id"], name: "index_study_result_trial_results_on_experiment_id"
    t.index ["phase_definition_id"], name: "index_study_result_trial_results_on_phase_definition_id"
    t.index ["protocol_user_id"], name: "index_study_result_trial_results_on_protocol_user_id"
    t.index ["trial_definition_id"], name: "index_study_result_trial_results_on_trial_definition_id"
  end

  create_table "trial_definitions", id: :serial, force: :cascade do |t|
    t.string "definition_data"
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.integer "phase_definition_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.string "description"
    t.index ["phase_definition_id"], name: "index_trial_definitions_on_phase_definition_id"
    t.index ["protocol_definition_id"], name: "index_trial_definitions_on_protocol_definition_id"
    t.index ["study_definition_id"], name: "index_trial_definitions_on_study_definition_id"
  end

  create_table "trial_order_selection_mappings", id: :serial, force: :cascade do |t|
    t.integer "trial_order_id"
    t.integer "user_id"
    t.integer "phase_definition_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["phase_definition_id"], name: "index_trial_order_selection_mappings_on_phase_definition_id"
    t.index ["trial_order_id"], name: "index_trial_order_selection_mappings_on_trial_order_id"
    t.index ["user_id"], name: "index_trial_order_selection_mappings_on_user_id"
  end

  create_table "trial_orders", id: :serial, force: :cascade do |t|
    t.string "sequence_data"
    t.integer "study_definition_id", null: false
    t.integer "protocol_definition_id", null: false
    t.integer "phase_definition_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["phase_definition_id"], name: "index_trial_orders_on_phase_definition_id"
    t.index ["protocol_definition_id"], name: "index_trial_orders_on_protocol_definition_id"
    t.index ["study_definition_id"], name: "index_trial_orders_on_study_definition_id"
    t.index ["user_id"], name: "index_trial_orders_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.boolean "anonymous"
    t.string "role"
    t.string "username"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "trial_order_selection_mappings", "phase_definitions"
  add_foreign_key "trial_order_selection_mappings", "trial_orders"
  add_foreign_key "trial_order_selection_mappings", "users"
end
