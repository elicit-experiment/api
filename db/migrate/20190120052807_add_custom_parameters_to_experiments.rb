# frozen_string_literal: true

class AddCustomParametersToExperiments < ActiveRecord::Migration[5.1]
  def change
    add_column :study_result_experiments, :custom_parameters, :jsonb
  end
end
