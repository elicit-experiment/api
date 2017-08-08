class CreateProtocols < ActiveRecord::Migration[5.1]
  def change
    create_table :protocols do |t|
      t.string :Name
      t.integer :Version
      t.string :Type
      t.string :DefinitionData

      t.timestamps
    end
  end
end
