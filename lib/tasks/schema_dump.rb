Rake::Task['db:schema:dump'].enhance do
  # Idea from https://www.gamecreatures.com/blog/2022/12/29/rails-generate-both-structure-sql-and-schema-rb/, updated for Rails 7.2
  File.open(Rails.root.join('db/schema.rb'), 'w') do |stream|
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base, stream)
  end
end