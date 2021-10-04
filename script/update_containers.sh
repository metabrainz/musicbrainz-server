#!/usr/bin/env bash

set -e -u

SCRIPT_NAME=$(basename "$0")

LIST_METABRAINZ_HOSTS_DEFAULT='../docker-server-configs/scripts/list_nodes.sh'

HELP=$(cat <<EOH
Usage: $SCRIPT_NAME <prod|beta|test> [<hosts list>]

Update MusicBrainz website/webservice containers on specified hosts.
If no (space-delimited) hosts list is specified, update on all hosts
listed as relevant using your working copy of docker-server-configs.

Please make sure that your working copy is up-to-date beforehand!

Environment:

  LIST_METABRAINZ_HOSTS
    Path to the script that lists MetaBrainz hosts by service.
    Default: $LIST_METABRAINZ_HOSTS_DEFAULT
EOH
)

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)

cd "$MB_SERVER_ROOT"

if [ $# -eq 0 ]
then
  echo >&2 "$SCRIPT_NAME: missing arguments"
  echo >&2 "$HELP"
  exit 64
elif echo "$1" | grep -Eqx -- '-*h(elp)?'
then
  echo "$HELP"
  exit
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
  LIST_METABRAINZ_HOSTS=${LIST_METABRAINZ_HOSTS:-$LIST_METABRAINZ_HOSTS_DEFAULT}
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
  for service in $SERVICES
  do
    container="$service-$DEPLOY_ENV"
    echo "$host: Putting $container into maintenance mode..."

    ssh "$host" \
      sudo -H -S -- \
        /root/docker-server-configs/scripts/set_service_maintenance.sh \
          enable \
          "$container" \
          5000
  done

  # Production value of DETERMINE_MAX_REQUEST_TIME
  sleep 60

  echo "$host: Updating containers..."
  ssh "$host" \
    sudo -H -S -- \
      /root/docker-server-configs/scripts/update_services.sh \
        $DEPLOY_ENV $SERVICES

  for service in $SERVICES
  do
    container="$service-$DEPLOY_ENV"
    http_status=0
    while [[ $http_status -ne 200 ]]
    do
      http_status=$(
        ssh "$host" \
          docker exec "$container" \
            curl -I -s -o /dev/null -w "%{http_code}" 'http://localhost:5000'
      )
      if [[ $http_status -eq 200 ]]
      then
        break
      else
        echo "$host: Waiting for $container to come back up..."
        sleep 1
      fi
    done

    echo "$host: Bringing $container out of maintenance mode..."
    ssh "$host" \
      sudo -H -S -- \
        /root/docker-server-configs/scripts/set_service_maintenance.sh \
          disable \
          "$container" \
          5000
  done
done

# vi: set et sts=2 sw=2 ts=2 :
