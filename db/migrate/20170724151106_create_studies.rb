class CreateStudies < ActiveRecord::Migration[5.1]
  def change
    create_table :studies do |t|
      t.string :title
      t.references :principal_investigator_user, foreign_key: { to_table: :users }, index: true

      t.timestamps
    end
  end
end
