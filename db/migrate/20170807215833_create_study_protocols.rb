class CreateStudyProtocols < ActiveRecord::Migration[5.1]
  def change
    create_join_table :studies, :protocols
  end
end
