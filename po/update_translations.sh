#!/usr/bin/env bash

set -e -u

SCRIPT_NAME=$(basename "$0")

HELP=$(cat <<EOH
Usage: $SCRIPT_NAME [option]"

Download latest translations from Transifex.

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
  sed -E 's/^ *> ?//' >&2 << ..EOM
  > $SCRIPT_NAME: Git working tree has local changes already
  >
  > Your local changes would be incidentally committed with translations.
  > Please clean your Git working tree before updating translations.
..EOM
  exit 70
fi

cd po

git rm mb_server.{es_ES,el_GR}.po
tx pull -f
perl -pi -e 's/(Last-Translator: .*<)[^<>]+(>\\n")$/$1email address hidden$2/' -- *.po
perl -pi -e 's/^(#.*<)[^<>]+(>, [0-9]+.*)$/$1email address hidden$2/' -- *.po
perl -pi -e 's/ENCODING/8bit/' -- *.po
git checkout HEAD mb_server.{es_ES,el_GR}.po

if [ $DO_COMMIT = 'yes' ]
then
  if git diff --quiet
  then
    echo "Translations already up-to-date, nothing to commit."
  else
    git add -- *.po
    git commit -m 'Update translations from Transifex'
    git show --stat
  fi
fi

# vi: set et sts=2 sw=2 ts=2 :
