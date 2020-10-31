# frozen_string_literal: true

class AddNameToTrialDefinitions < ActiveRecord::Migration[5.1]
  def change
    add_column :trial_definitions, :name, :string
    add_column :trial_definitions, :description, :string
  end
end
