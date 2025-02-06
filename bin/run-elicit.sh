#!/usr/bin/env bash

if [ "$CONTAINER_ROLE" = "jobs" ]; then
  source "$(dirname "$0")/run-jobs-role.sh"
elif [ "$CONTAINER_ROLE" = "web" ]; then
  source "$(dirname "$0")/run-web-role.sh"
else
  echo "Error: Invalid CONTAINER_ROLE. Expected 'jobs' or 'web'."
  exit 1
fi
