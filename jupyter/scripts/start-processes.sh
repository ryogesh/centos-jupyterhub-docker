#!/bin/bash

set -e

echo "starting cron daemon"
crond -m off

echo "starting jupyter notebook with parameters:$@"
start-notebook.sh "$@"

