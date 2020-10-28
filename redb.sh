#!/bin/bash

bundle exec rake db:drop
bundle exec rake db:create
bundle exec rake db:structure:load
bundle exec rake db:migrate
bundle exec rake db:seed

