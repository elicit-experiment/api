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

ActiveRecord::Schema.define(version: 20170829210919) do

  #
  # Users
  #

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

    #
    # Chaos interop.
    # 

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
    t.boolean "preview"
    t.string "url", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  #
  # AuthN/AuthZ
  #
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

  #
  # Study Definition
  #

  create_table "media_files", force: :cascade do |t|
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  #
  # Study Definition
  #

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
    t.index ["principal_investigator_user_id"], name: "index_study_definitions_on_principal_investigator_user_id"
  end

  create_table "protocol_definitions", force: :cascade do |t|
    t.string "name"
    t.integer "version"
    t.string "type"
    t.string "summary"
    t.string "description"
    t.string "definition_data"
    t.boolean "active", default: false, null: false
    t.references "study_definition", foreign_key: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "protocol_users", force: :cascade do |t|
    t.references "user", foreign_key: true, null: false
    t.references "protocol_definition", foreign_key: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "phase_definitions", force: :cascade do |t|
    t.string "definition_data"
    t.references "study_definition", foreign_key: true, null: false
    t.references "protocol_definition", foreign_key: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "phase_orders", force: :cascade do |t|
    t.string "sequence_data"
    t.references "study_definition", foreign_key: true, null: false
    t.references "protocol_definition", foreign_key: true, null: false
    t.references "user", foreign_key: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trial_definitions", force: :cascade do |t|
    t.string "definition_data"
    t.references "study_definition", foreign_key: true, null: false
    t.references "protocol_definition", foreign_key: true, null: false
    t.references "phase_definition", foreign_key: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trial_orders", force: :cascade do |t|
    t.string "sequence_data"
    t.references "study_definition", foreign_key: true, null: false
    t.references "protocol_definition", foreign_key: true, null: false
    t.references "phase_definition", foreign_key: true, null: false
    t.references "user", foreign_key: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stimuli", force: :cascade do |t|
    t.string "definition_data"
    t.references "study_definition", foreign_key: true, null: false
    t.references "protocol_definition", foreign_key: true, null: false
    t.references "phase_definition", foreign_key: true, null: false
    t.references "trial_definition", foreign_key: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "components", force: :cascade do |t|
    t.string "definition_data"
    t.references "study_definition", foreign_key: true, null: false
    t.references "protocol_definition", foreign_key: true, null: false
    t.references "phase_definition", foreign_key: true, null: false
    t.references "trial_definition", foreign_key: true, null: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end


  #
  # Study Results
  #

  create_table "study_result_study_results", force: :cascade do |t|
    t.references "study_definition", foreign_key: true
    t.references "user", foreign_key: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
  end

  create_table "study_result_experiments", force: :cascade do |t|
    t.integer "study_result_id", null: false
    t.references "protocol_user", foreign_key: true, null: false
    t.integer "current_stage_id", null: true
    t.integer "num_stages_completed", null: true
    t.integer "num_stages_remaining", null: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
  end

  add_foreign_key "study_result_experiments", "study_result_study_results", column: "study_result_id"

  create_table "study_result_stages", force: :cascade do |t|
    t.integer "experiment_id", null: false
    t.references "protocol_user", foreign_key: true, null: false
    t.references "phase_definition", foreign_key: true, null: false
    t.integer "last_completed_trial", null: true
    t.integer "current_trial"
    t.integer "num_trials"
    t.integer "context_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
  end

  add_foreign_key "study_result_stages", "study_result_experiments", column: "experiment_id"

  create_table "study_result_trial_results", force: :cascade do |t|
    t.integer "experiment_id", null: false
    t.references "protocol_user", foreign_key: true, null: false
    t.references "phase_definition", foreign_key: true, null: false
    t.references "trial_definition", foreign_key: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
    t.datetime "started_at"
  end

  add_foreign_key "study_result_trial_results", "study_result_experiments", column: "experiment_id"

  add_foreign_key "study_result_experiments", "study_result_stages", column: "current_stage_id"

  create_table "study_result_contexts", force: :cascade do |t|
    t.datetime "datetime"
    t.text "context_type"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_result_data_points", force: :cascade do |t|
    t.integer "stage_id", null: false
    t.references "protocol_user", foreign_key: true
    t.references "phase_definition", foreign_key: true
    t.references "trial_definition", foreign_key: true
    t.references "component", foreign_key: true
    t.string "kind"
    t.string "point_type"
    t.string "value"
    t.string "method"
    t.datetime "datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "study_result_data_points", "study_result_stages", column: "stage_id"

  create_table "study_result_time_series", force: :cascade do |t|
    t.integer "stage_id"
    t.integer "study_result_id"
    t.references "protocol_user", foreign_key: true
    t.references "phase_definition", foreign_key: true
    t.references "trial_definition", foreign_key: true
    t.references "component", foreign_key: true
    t.string "file"
    t.string "schema"
    t.string "schema_metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "study_result_time_series", "study_result_stages", column: "stage_id"
  add_foreign_key "study_result_time_series", "study_result_study_result", column: "study_result_id"
end
