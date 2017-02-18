class CreateTrials < ActiveRecord::Migration[5.0]
  def change
    create_table :trials do |t|
      t.integer :task_id
      t.references :experiment, foreign_key: true

      t.timestamps
    end
  end
end
