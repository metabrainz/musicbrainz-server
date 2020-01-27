#!/usr/bin/env bash

set -e -u

SCRIPT_NAME=$(basename "$0")

HELP=$(cat <<EOH
Usage: $SCRIPT_NAME [option]"

Update POT files from codebase and production database.

Option:
  --commit  Commit changes to Git, if any
EOH
)

if [ $# -gt 1 ]
then
  echo >&2 "$SCRIPT_NAME: too many arguments"
  echo >&2 "$HELP"
  exit 64
elif [ $# -eq 1 ]
then
  if [ "$1" != '--commit' ]
  then
    echo >&2 "$SCRIPT_NAME: unrecognized option: $1"
    echo >&2 "$HELP"
    exit 64
  fi
  DO_COMMIT='yes'
else
  DO_COMMIT='no'
fi

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)

cd "$MB_SERVER_ROOT"

if [ $DO_COMMIT = 'yes' ] && \
  ! (git diff --quiet && git diff --cached --quiet)
then
  echo >&2 "$SCRIPT_NAME: Git working tree has local changes already"
  echo >&2
  echo >&2 "Your local changes would be incidentally committed with POT files."
  echo >&2 "Please clean your Git working tree before updating POT files."
  exit 70
fi

export MB_POT_DB=PROD_STANDBY

if ! script/database_exists $MB_POT_DB
then
  exit 78
fi

cd po

touch extract_pot_db extract_pot_templates
make pot

if [ $DO_COMMIT = 'yes' ]
then
  if git diff --quiet
  then
    echo "POT files already up-to-date, nothing to commit."
  else
    git add -- *.po
    git commit -m 'Update POT files using the production database'
    git show --stat
  fi
fi

# vi: set et sts=2 sw=2 ts=2 :
