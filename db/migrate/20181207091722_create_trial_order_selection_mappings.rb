# frozen_string_literal: true

class CreateTrialOrderSelectionMappings < ActiveRecord::Migration[5.1]
  def change
    create_table :trial_order_selection_mappings do |t|
      t.references :trial_order, foreign_key: true
      t.references :user, foreign_key: true
      t.references :phase_definition, foreign_key: true

      t.timestamps
    end
  end
end
