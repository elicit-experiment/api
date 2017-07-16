class CreateContexts < ActiveRecord::Migration[5.0]
  def change
    create_table :contexts do |t|
      t.datetime :DateTime
      t.text :Type
      t.text :Data
      t.string :ExperimentId
      t.string :QuestionId
      t.string :TrialId

      t.timestamps
    end
  end
end
