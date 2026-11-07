# frozen_string_literal: true

class AddCustomParametersToExperiments < ActiveRecord::Migration[5.1]
  def change
    type = connection.adapter_name == 'PostgreSQL' ? :jsonb : :json
    add_column :study_result_experiments, :custom_parameters, type
  end
end
