#!/usr/bin/env bash

set -e -u

SCRIPT_NAME=$(basename "$0")

HELP=$(cat <<EOH
Usage: $SCRIPT_NAME"

Create and push a Git tag on 'production' branch.
EOH
)

if [ $# -gt 0 ]
then
  echo >&2 "$SCRIPT_NAME: too many arguments"
  echo >&2 "$HELP"
  exit 64
fi

if ! (git diff --quiet && git diff --cached --quiet)
then
  echo >&2 "$SCRIPT_NAME: Git working tree has local changes"
  echo >&2
  echo >&2 "Your local changes might be missing from 'production' branch."
  echo >&2 "Please clean your Git working tree before tagging 'production'."
  exit 70
fi

year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)

tag="v-$year-$month-$day"
read -e -i "$tag" -p 'Tag? ' -r tag

blog_url="https://blog.metabrainz.org/$year/$month/$day/"
blog_url+="server-update-$year-$month-$day/"
read -e -i "$blog_url" -p 'Blog post URL? ' -r blog_url

set -x
git tag -u CE33CF04 "$tag" -m "$blog_url" production
git push origin "$tag"

# vi: set et sts=2 sw=2 ts=2 :
