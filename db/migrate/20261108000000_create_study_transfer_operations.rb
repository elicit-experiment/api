# frozen_string_literal: true

class CreateStudyTransferOperations < ActiveRecord::Migration[7.2]
  def change
    create_table :canonical_study_revisions do |t|
      t.references :study_definition, null: false, foreign_key: true
      t.string :definition_digest, null: false
      t.string :contract_digest, null: false
      t.json :compiled_contract, null: false
      t.datetime :created_at, null: false
    end
    add_index :canonical_study_revisions, %i[study_definition_id definition_digest], unique: true, name: 'canonical_revision_identity'

    create_table :study_transfer_operations do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :study_definition, foreign_key: true
      t.references :canonical_study_revision, foreign_key: true
      t.string :kind, null: false
      t.string :status, null: false, default: 'queued'
      t.string :phase, null: false, default: 'queued'
      t.string :idempotency_key, null: false
      t.string :request_digest, null: false
      t.json :options, null: false, default: {}
      t.json :diagnostics, null: false, default: []
      t.json :result, null: false, default: {}
      t.string :claim_token
      t.datetime :lease_expires_at
      t.timestamps
    end
    add_index :study_transfer_operations, %i[requester_id idempotency_key], unique: true, name: 'study_transfer_idempotency'
    add_index :study_transfer_operations, %i[status lease_expires_at]

    create_table :canonical_result_rows do |t|
      t.references :canonical_study_revision, null: false, foreign_key: true
      t.references :study_transfer_operation, null: false, foreign_key: true
      t.string :table_name, null: false
      t.string :participant_id, null: false
      t.string :row_key, null: false
      t.json :payload, null: false
    end
    add_index :canonical_result_rows, %i[canonical_study_revision_id table_name row_key], unique: true, name: 'canonical_result_identity'
    add_index :canonical_result_rows, %i[canonical_study_revision_id participant_id], name: 'canonical_participant_results'
  end
end
