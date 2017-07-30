#!/bin/bash

# generate a new secret key on every startup
SECRET_KEY_BASE=$SECRET_KEY_BASE
: ${SECRET_KEY_BASE:=`cat ~/secret-key-base.txt`}
export SECRET_KEY_BASE=$SECRET_KEY_BASE

cp -R public/* /var/www/app/public/

# The default command that gets ran will be to start the Puma server.
RAILS_ENV=production bundle exec puma -C config/puma.rb
