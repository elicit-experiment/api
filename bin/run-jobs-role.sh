#!/usr/bin/env bash

: "${RAILS_ENV:=production}"
export RAILS_ENV

rm -rf /var/www/app/public
ln -s /var/www/app/public/ public

bundle exec bin/jobs
