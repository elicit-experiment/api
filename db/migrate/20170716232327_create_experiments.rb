class CreateExperiments < ActiveRecord::Migration[5.0]
  def change
    create_table :experiments do |t|
      t.string :ExperimentId
      t.string :Name
      t.integer :Version
      t.text :ExperimentDescription
      t.string :CreatedBy
      t.text :Data
      t.integer :LockQuestion
      t.integer :EnablePrevious
      t.integer :NoOfTrials
      t.integer :TrialsCompleted
      t.text :FooterLabel
      t.string :RedirectOnCloseUrl
      t.string :FileName

      t.timestamps
    end
  end
end
