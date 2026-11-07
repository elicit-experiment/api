# frozen_string_literal: true

# Read-only comparison of the logical schema loaded by each adapter in CI.
# Run with: RAILS_ENV=test bin/rails runner test/database/schema_signature.rb OUTPUT.json
raise 'Schema comparison requires the test environment' unless Rails.env.test?

require 'json'

signature = %w[primary queue].to_h do |name|
  config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: name)
  ActiveRecord::Base.establish_connection(config)
  connection = ActiveRecord::Base.connection
  tables = (connection.tables - %w[schema_migrations ar_internal_metadata]).sort.to_h do |table|
    columns = connection.columns(table).sort_by(&:name).map do |column|
      default = case column.type
                when :boolean then ActiveModel::Type::Boolean.new.cast(column.default)
                when :integer then column.default&.to_i
                else column.default
                end
      [column.name, column.type == :jsonb ? :json : column.type, column.null, default]
    end
    indexes = connection.indexes(table).sort_by(&:name).map { |index| [index.name, index.columns, index.unique] }
    foreign_keys = connection.foreign_keys(table).map do |key|
      [key.column, key.to_table, key.primary_key, key.on_delete]
    end.sort_by(&:to_s)
    [table, { primary_key: connection.primary_key(table), columns: columns, indexes: indexes, foreign_keys: foreign_keys }]
  end
  [name, tables]
end
File.write(ARGV.fetch(0), JSON.pretty_generate(signature) + "\n")
