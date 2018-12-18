class AddUserDeclarationsToStudyDefinition < ActiveRecord::Migration[5.1]
  def change
    add_column :study_definitions, :allow_anonymous_users, :boolean
    add_column :study_definitions, :show_in_study_list, :boolean
    add_column :study_definitions, :max_anonymous_users, :integer
  end
end
