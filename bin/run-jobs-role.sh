#!/usr/bin/env bash

: "${RAILS_ENV:=production}"
export RAILS_ENV

bundle exec bin/jobs
