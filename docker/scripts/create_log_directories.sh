#!/usr/bin/env bash

set -e -u

SCRIPT_NAME=$(basename "$0")

if ((BASH_VERSINFO[0] < 4))
then
  echo >&2 "$SCRIPT_NAME: at least version 4 of bash is required"
  echo >&2 "Make sure this version of bash comes first in \$PATH"
  exit 69 # EX_UNAVAILABLE
fi

declare -rA log_directories_by_container_type=(
  ['production-cron']='daily hourly monthly occasionally'
  ['json-dump']='daily-json-dump hourly-json-dump occasionally'
  ['search-indexes-dump']='daily-search-indexes-dump hourly-search-indexes-dump occasionally'
  ['sitemaps']='daily-sitemaps hourly-sitemaps occasionally'
)

HELP=$(cat <<EOH
Usage: $SCRIPT_NAME

This script is meant to be used in production only, to create the
directories for log files when starting up a container of the type
indicated by the environment variable MB_CONTAINER_TYPE among:
${!log_directories_by_container_type[@]}

EOH
)

if [[ $# -ne 0 && $1 =~ ^-*h(elp)?$ ]]
then
  echo "$HELP"
  exit 0 # EX_OK
elif [[ $# -ne 0 ]]
then
  echo >&2 "$SCRIPT_NAME takes no argument."
  echo >&2 "Try '$SCRIPT_NAME help' for usage."
  exit 64 # EX_USAGE
fi

# shellcheck disable=SC2076
if [[ ! " ${!log_directories_by_container_type[*]} " =~ " $MB_CONTAINER_TYPE " ]]
then
  echo >&2 "$SCRIPT_NAME: unrecognized value of MB_CONTAINER_TYPE: $MB_CONTAINER_TYPE"
  echo >&2 "Try '$SCRIPT_NAME help' for usage."
  exit 64 # EX_USAGE
fi

MB_LOG_ROOT=/home/musicbrainz/log

for directory in ${log_directories_by_container_type[$MB_CONTAINER_TYPE]}
do
  sudo -u musicbrainz -- mkdir -p "$MB_LOG_ROOT/$directory"
done

# vi: set et sts=2 sw=2 ts=2 :
