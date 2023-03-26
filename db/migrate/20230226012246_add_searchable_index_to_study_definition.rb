class AddSearchableIndexToStudyDefinition < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :study_definitions, :searchable, using: :gin, algorithm: :concurrently
  end
end
