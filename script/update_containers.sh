#!/usr/bin/env bash

set -e -u

SCRIPT_NAME=$(basename "$0")

HELP=$(cat <<EOH
Usage: $SCRIPT_NAME <prod|beta|test> [<hosts list>]"

Update MusicBrainz website/webservice containers on specified hosts.
If no (space-delimited) hosts list is specified, update on all hosts
listed as relevant using your working copy of docker-server-configs.

Please make sure that your working copy is up-to-date beforehand!
EOH
)

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)

cd "$MB_SERVER_ROOT"

if [ $# -eq 0 ]
then
  echo >&2 "$SCRIPT_NAME: missing arguments"
  echo >&2 "$HELP"
  exit 64
elif echo "$1" | grep -Eqvx 'prod|beta|test'
then
  echo >&2 "$SCRIPT_NAME: unrecognized argument: $1"
  echo >&2 "$HELP"
  exit 64
fi

DEPLOY_ENV=$1
shift

SERVICES="musicbrainz-webservice musicbrainz-website"

if [ $# -eq 0 ]
then
  LIST_METABRAINZ_HOSTS=${LIST_METABRAINZ_HOSTS:-../docker-server-configs/scripts/list_nodes.sh}
  if [ ! -x "$LIST_METABRAINZ_HOSTS" ]
  then
    echo >&2 "$SCRIPT_NAME: cannot list hosts per service/deploy env"
    echo >&2
    echo >&2 "Please set \$LIST_METABRAINZ_HOSTS or specify hosts list"
    exit 69
  fi

  HOSTS=$(
    for service in $SERVICES
    do
      "$LIST_METABRAINZ_HOSTS" "$service" "$DEPLOY_ENV"
    done | sort -u
  )
else
  if [ $# -eq 0 ]
  then
    echo >&2 "$SCRIPT_NAME: missing (space-separated) hosts list"
    echo >&2 "$HELP"
    exit 64
  fi

  HOSTS="$*"
fi

for host in $HOSTS
do
  echo "$host: Updating containers..."
  ssh "$host" \
    sudo -H -S -- \
      /root/docker-server-configs/scripts/update_services.sh \
        $DEPLOY_ENV $SERVICES
  sleep 30
done

# vi: set et sts=2 sw=2 ts=2 :
