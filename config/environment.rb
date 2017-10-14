# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Add the services folder to the autoload path
Rails.application.configure do
  config.autoload_paths << "#{Rails.root}/app/services"
end