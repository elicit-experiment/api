require 'active_record/database_configurations'

required_keys = %w[API_SCHEME EXTERNAL_API_SCHEME API_URL ELICIT_URL SITE_SUFFIX
REDIS_PASSWORD SECRET_KEY_BASE PUBLIC_CLIENT_ID PUBLIC_CLIENT_SECRET ADMIN_USER
ADMIN_PASSWORD SUBJECT_DEFAULT_PASSWORD]

# Resolve Rails' effective adapter, including DATABASE_URL overrides, without a DB query.
primary = ActiveRecord::DatabaseConfigurations.new(Rails.application.config.database_configuration)
                                            .configs_for(env_name: Rails.env, name: 'primary')
required_keys.concat(%w[POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB]) if primary.adapter == 'postgresql'
Dotenv.require_keys(*required_keys)
