# frozen_string_literal: true

require 'test_helper'
require 'erb'
require 'yaml'

class DatabaseConfigurationTest < ActiveSupport::TestCase
  def database_config(overrides)
    keys = %w[DATABASE_ADAPTER DATABASE_URL PRIMARY_DATABASE_URL QUEUE_DATABASE_URL SQLITE_DATABASE_DIR]
    before = (keys + overrides.keys).uniq.to_h { |key| [key, ENV[key]] }
    keys.each { |key| ENV.delete(key) }
    overrides.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    YAML.safe_load(ERB.new(Rails.root.join('config/database.yml').read).result, aliases: true)
  ensure
    before&.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  test 'PostgreSQL remains the default with existing database names and credentials' do
    config = database_config('POSTGRES_USER' => 'existing', 'POSTGRES_PASSWORD' => 'existing-secret',
                             'POSTGRES_DB' => 'existing-production')
    assert_equal 'postgresql', config.dig('production', 'primary', 'adapter')
    assert_equal 'existing-production', config.dig('production', 'primary', 'database')
    assert_equal 'existing', config.dig('production', 'primary', 'username')
    assert_equal 'elicit_test', config.dig('test', 'primary', 'database')
    assert_equal 'app_production_queue', config.dig('production', 'queue', 'database')
  end

  test 'SQLite separates environments, queue files and adapter-specific schema dumps' do
    config = database_config('DATABASE_ADAPTER' => 'sqlite3', 'SQLITE_DATABASE_DIR' => '/persistent/data')
    paths = config.values.flat_map { |env| env.values.grep(Hash).map { |db| db['database'] } }
    assert_equal 6, paths.size
    assert_equal paths.uniq, paths
    assert_equal '/persistent/data/production.sqlite3', config.dig('production', 'primary', 'database')
    assert_equal 'sqlite_schema.rb', config.dig('production', 'primary', 'schema_dump')
    assert_equal 'sqlite_queue_schema.rb', config.dig('production', 'queue', 'schema_dump')
  end

  test 'standard SQLite URLs select the SQLite schema configuration' do
    config = database_config('DATABASE_URL' => 'sqlite3:/persistent/custom.sqlite3')
    assert_equal 'sqlite3', config.dig('production', 'primary', 'adapter')
    assert_equal 'sqlite_schema.rb', config.dig('production', 'primary', 'schema_dump')
  end

  test 'conflicting and unknown adapter selections fail before database access' do
    assert_raises(RuntimeError) { database_config('DATABASE_ADAPTER' => 'mysql2') }
    assert_raises(RuntimeError) do
      database_config('DATABASE_ADAPTER' => 'sqlite3', 'DATABASE_URL' => 'postgresql://localhost/existing')
    end
  end
end
