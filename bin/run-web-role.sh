#!/usr/bin/env bash

: "${RAILS_ENV:=production}"
export RAILS_ENV

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

env PRECOMPILE=1 bundle exec rake db:migrate

# The default command that gets ran will be to start the Puma server.
RUBYOPT=--yjit bundle exec puma -C config/puma.rb
