class CreateStudyProtocols < ActiveRecord::Migration[5.1]
  def change
    create_join_table :protocols, :studies
  end
end
