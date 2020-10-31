# frozen_string_literal: true

class AddNewEventModelParameters < ActiveRecord::Migration[5.1]
  def change
    add_column :study_result_data_points, :entity_type, :string
    add_column :components, :name, :string
  end
end
