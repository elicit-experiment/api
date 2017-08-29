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

ActiveRecord::Schema.define(version: 20170809222613) do

  create_table "contexts", force: :cascade do |t|
    t.datetime "DateTime"
    t.text "Type"
    t.text "Data"
    t.string "ExperimentId"
    t.string "QuestionId"
    t.string "TrialId"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.datetime "DateTime"
    t.text "EventId"
    t.text "Type"
    t.text "Method"
    t.text "Data"
    t.string "ExperimentId"
    t.string "QuestionId"
    t.string "TrialId"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "experiments", force: :cascade do |t|
    t.string "ExperimentId"
    t.string "Name"
    t.integer "Version"
    t.text "ExperimentDescription"
    t.string "CreatedBy"
    t.text "Data"
    t.integer "LockQuestion"
    t.integer "EnablePrevious"
    t.integer "NoOfTrials"
    t.integer "TrialsCompleted"
    t.text "FooterLabel"
    t.string "RedirectOnCloseUrl"
    t.string "FileName"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.boolean "anonymous"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_definitions", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.references :principal_investigator_user, index: true, null: false, foreign_key: { to_table: :users }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "protocol_definitions", force: :cascade do |t|
    t.string "Name"
    t.integer "Version"
    t.string "Type"
    t.string "DefinitionData"
    t.references :study_definition, index: true, null: false, foreign_key: { to_table: :study_definitions }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "phase_definitions", force: :cascade do |t|
    t.string "DefinitionData"
    t.references :study_definition, index: true, null: false, foreign_key: { to_table: :study_definitions }
    t.references :protocol_definition, index: true, null: false, foreign_key: { to_table: :protocol_definitions }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "phase_orders", force: :cascade do |t|
    t.string "SequenceData"
    t.references :study_definition, index: true, null: false, foreign_key: { to_table: :study_definitions }
    t.references :protocol_definition, index: true, null: false, foreign_key: { to_table: :protocol_definitions }
    t.references :user, index: true, null: false, foreign_key: { to_table: :users }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trial_definitions", force: :cascade do |t|
    t.string "DefinitionData"
    t.references :study_definition, index: true, null: false, foreign_key: { to_table: :study_definitions }
    t.references :protocol_definition, index: true, null: false, foreign_key: { to_table: :protocol_definitions }
    t.references :phase_definition, index: true, null: false, foreign_key: { to_table: :phase_definitions }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trial_orders", force: :cascade do |t|
    t.string "SequenceData"
    t.references :study_definition, index: true, null: false, foreign_key: { to_table: :study_definitions }
    t.references :protocol_definition, index: true, null: false, foreign_key: { to_table: :protocol_definitions }
    t.references :phase_definition, index: true, null: false, foreign_key: { to_table: :phase_definitions }
    t.references :user, index: true, null: false, foreign_key: { to_table: :users }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "components", force: :cascade do |t|
    t.string "DefinitionData"
    t.references :trial_definition, index: true, null: false, foreign_key: { to_table: :trial_definitions }
    t.references :study_definition, index: true, null: false, foreign_key: { to_table: :study_definitions }
    t.references :protocol_definition, index: true, null: false, foreign_key: { to_table: :protocol_definitions }
    t.references :phase_definition, index: true, null: false, foreign_key: { to_table: :phase_definitions }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stimuli", force: :cascade do |t|
    t.string "DefinitionData"
    t.references :trial_definition, index: true, null: false, foreign_key: { to_table: :trial_definitions }
    t.references :study_definition, index: true, null: false, foreign_key: { to_table: :study_definitions }
    t.references :protocol_definition, index: true, null: false, foreign_key: { to_table: :protocol_definitions }
    t.references :phase_definition, index: true, null: false, foreign_key: { to_table: :phase_definitions }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "protocols_studies", id: false, force: :cascade do |t|
    t.references :study_definition, index: true, null: false, foreign_key: { to_table: :study_definitions }
    t.references :protocol_definition, index: true, null: false, foreign_key: { to_table: :protocol_definitions }
    t.integer "sequence_no", null: false
  end
end
