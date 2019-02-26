#!/bin/bash

# generate a new secret key on every startup
SECRET_KEY_BASE=$SECRET_KEY_BASE
: ${SECRET_KEY_BASE:=`cat ~/secret-key-base.txt`}
export SECRET_KEY_BASE=$SECRET_KEY_BASE

mv public public_init
rm -rf /var/www/app/public/assets
cp -R public_init/* /var/www/app/public/
ln -s /var/www/app/public/ public

# copy awesome print config for production
cp ./.aprc.production ~/.aprc

# start from scratch
#DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production PRECOMPILE=1 bundle exec rake db:drop
#DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production PRECOMPILE=1 bundle exec rake db:setup
#DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production PRECOMPILE=1 bundle exec rake db:seed

RAILS_ENV=production PRECOMPILE=1 bundle exec rake db:migrate

# The default command that gets ran will be to start the Puma server.
RAILS_ENV=production bundle exec puma -C config/puma.rb
