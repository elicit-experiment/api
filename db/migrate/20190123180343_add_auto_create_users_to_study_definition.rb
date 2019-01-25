class AddAutoCreateUsersToStudyDefinition < ActiveRecord::Migration[5.1]
  def change
    add_column :study_definitions, :auto_created_user_count, :integer, default: 0
    add_column :study_definitions, :max_auto_created_users, :integer, default: 0
    add_column :study_definitions, :max_concurrent_users, :integer
  end
end
