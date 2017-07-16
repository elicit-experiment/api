class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.datetime :DateTime
      t.text :EventId
      t.text :Type
      t.text :Method
      t.text :Data
      t.string :ExperimentId
      t.string :QuestionId
      t.string :TrialId

      t.timestamps
    end
  end
end
