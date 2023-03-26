class AddSearchableToStudyDefinition < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE study_definitions
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description,'')), 'B')
      ) STORED;
    SQL
  end

  def down
    remove_column :study_definitions, :searchable
  end
end
