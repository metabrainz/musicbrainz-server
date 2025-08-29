#!/usr/bin/env bash

set -e -o pipefail -u

SCRIPT_NAME=$(basename "$0")

HELP=$(cat <<EOH
Usage: $SCRIPT_NAME

Test that no admin files contain any translatable messages (MBS-13117).
EOH
)

if [ $# -gt 1 ]
then
  echo >&2 "$SCRIPT_NAME: too many arguments"
  echo >&2 "$HELP"
  exit 64
elif [ $# -eq 1 ]
then
  if echo "$1" | grep -Eqx -- '-*h(elp)?'
  then
    echo "$HELP"
    exit
  elif [ "$1" != '--commit' ]
  then
    echo >&2 "$SCRIPT_NAME: unrecognized option: $1"
    echo >&2 "$HELP"
    exit 64
  fi
fi

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)

cd "$MB_SERVER_ROOT"

echo "Testing that no admin files contain any translatable messages (MBS-13117)";

cd po

function sed_escape_spaces() {
  sed -e 's/ /\\ /g'
}

declare -a admin_perl_files=( $(git ls-files -- \
  ':(top,glob)lib/**/*Admin*.pm' \
  ':(top,glob)lib/**/*Admin*/**/*.pm' \
  | sed_escape_spaces) )

declare -a admin_tt_files=( $(git ls-files -- \
  ':(top,glob)root/admin/**/*.tt' \
  | sed_escape_spaces) )

declare -a admin_js_files=( $(git ls-files -- \
  ':(top,glob)root/admin/**/*.js' \
  | sed_escape_spaces) )

declare count=0

for file in ${admin_perl_files[@]}
do
  pot=`xgettext --from-code utf-8 --keyword=__ --keyword=l --keyword=lp:1,2c --keyword=N_lp:1,2c --keyword=N_l --keyword=ln:1,2 --keyword=N_ln:1,2 --keyword=__x --keyword=__nx:1,2 --keyword=__n:1,2 -Lperl -o - $file`
  if [ -n "$pot" ]
  then
    printf "$pot" | grep '^#:'
    count=`expr $count + 1`
  fi
done

for file in ${admin_tt_files[@]}
do
  pot=`./extract_pot_templates $file | sed '1,10d'`
  if [ -n "$pot" ]
  then
    printf "$pot" | grep '^#:'
    count=`expr $count + 1`
  fi
done

for file in ${admin_js_files[@]}
do
  pot=`../script/xgettext.js $file | sed '1,12d'`
  if [ -n "$pot" ]
  then
    printf "$pot" | grep '^#:'
    count=`expr $count + 1`
  fi
done

if [ $count -gt 0 ]
then
  echo "Error: Found $count admin files wrongly containing translatable messages"
  exit 1
else
  echo "OK"
fi

# vi: set et sts=2 sw=2 ts=2 :
