# frozen_string_literal: true

class AddTrialOrderingToPhaseDefinitions < ActiveRecord::Migration[5.1]
  def change
    add_column :phase_definitions, :trial_ordering, :string
  end
end
