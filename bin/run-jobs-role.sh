#!/usr/bin/env bash

: "${RAILS_ENV:=production}"
export RAILS_ENV

mv public public_init
rm -rf /var/www/app/public/assets
cp -R public_init/* /var/www/app/public/
ln -s /var/www/app/public/ public

bundle exec bin/jobs
