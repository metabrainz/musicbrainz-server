#!/usr/bin/env bash

set -x
shopt -s nullglob

function sv_start_if_down() {
  while [[ $# -gt 0 ]]
  do
    if [[ -e "/etc/service/$1/down" ]]
    then
      rm -fv "/etc/service/$1/down"
      sv start "$1"
    fi
    shift
  done
}

cd "$MBS_ROOT"

# Set the open file limit Solr requests on startup.
ulimit -n 65000

./docker/musicbrainz-tests/add_mbtest_alias.sh

service rabbitmq-server start

# Setup the rabbitmq user/vhost used by pg_amqp + sir.
rabbitmqctl add_user sir sir
rabbitmqctl add_vhost /sir-test
rabbitmqctl set_permissions -p /sir-test sir '.*' '.*' '.*'

export SIR_DIR=/home/musicbrainz/sir
pushd "$SIR_DIR"
# Setup the RabbitMQ channels/queues used by sir.
sudo -E -H -u musicbrainz sh -c '. venv/bin/activate; python -m sir amqp_setup'
popd

# GitHub Actions overrides the container entrypoint.
/sbin/my_init &
sleep 5

sv_start_if_down \
  artwork-indexer \
  artwork-redirect \
  postgresql \
  redis \
  solr \
  ssssss \
  template-renderer \
  website

# Wait for services to start.
sleep 10

sudo -E -H -u musicbrainz carton exec -- \
     ./t/selenium.js --browser-binary-path=/opt/chrome-linux64/chrome \
     | tee >(./node_modules/.bin/tap-junit > ./junit_output/selenium.xml) \
     | ./node_modules/.bin/tap-difflet

# Stop the template-renderer so that it dumps coverage.
sv down template-renderer
sleep 10

if [ "$GITHUB_ACTIONS" = 'true' ]; then
  if [[ -d .nyc_output && $(ls -A .nyc_output) ]]; then
      cp -Ra .nyc_output "$GITHUB_WORKSPACE"/nyc_output
  fi
  if [ -d junit_output ]; then
    cp -Ra junit_output "$GITHUB_WORKSPACE"
  fi
  logs="$GITHUB_WORKSPACE"/service_logs
  mkdir -p "$logs"
  for service in /var/log/service/*; do
      cp -a "$service"/current "$logs"/"$(basename "$service")".log
  done
  for sir_log in t/selenium/.sir-*.log; do
      base_fname="$(basename "$sir_log")"
      cp -a "$sir_log" "$logs"/"${base_fname#.}"
  done
fi

exit 0
