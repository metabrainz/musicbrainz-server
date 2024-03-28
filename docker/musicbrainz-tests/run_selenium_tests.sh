#!/usr/bin/env bash

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

cd /home/musicbrainz/musicbrainz-server

sv_start_if_down postgresql redis

# Wait for the database to start.
sleep 10

# Copy in DBDefs.pm, which is required before invoking create_test_db.sh.
sudo -E -H -u musicbrainz cp docker/musicbrainz-tests/DBDefs.pm lib/

# Create the musicbrainz_test and musicbrainz_selenium DBs.
sudo -E -H -u musicbrainz carton exec -- ./script/create_test_db.sh
pushd /var/lib/postgresql
sudo -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres \
     musicbrainz_selenium
popd

# Set the open file limit Solr requests on startup, then start Solr.
ulimit -n 65000
sv_start_if_down solr

# Setup the rabbitmq user/vhost used by pg_amqp + sir.
service rabbitmq-server start
rabbitmqctl add_user sir sir
rabbitmqctl add_vhost /sir-test
rabbitmqctl set_permissions -p /sir-test sir '.*' '.*' '.*'

# Install the sir triggers into musicbrainz_selenium.
export SIR_DIR=/home/musicbrainz/sir
cd "$SIR_DIR"
sudo -E -H -u musicbrainz sh -c '. venv/bin/activate; python -m sir amqp_setup; python -m sir extension; python -m sir triggers --broker-id=1'
psql -U postgres -f sql/CreateExtension.sql musicbrainz_selenium
psql -U musicbrainz -f sql/CreateFunctions.sql musicbrainz_selenium
psql -U musicbrainz -f sql/CreateTriggers.sql musicbrainz_selenium

# Install the artwork_indexer schema into musicbrainz_selenium.
cd /home/musicbrainz/artwork-indexer
psql -U musicbrainz -f sql/create_schema.sql musicbrainz_selenium
psql -U musicbrainz -f sql/caa_functions.sql musicbrainz_selenium
psql -U musicbrainz -f sql/caa_triggers.sql musicbrainz_selenium
psql -U musicbrainz -f sql/eaa_functions.sql musicbrainz_selenium
psql -U musicbrainz -f sql/eaa_triggers.sql musicbrainz_selenium

cd /home/musicbrainz/musicbrainz-server

# Start the various CAA-related services.
sv_start_if_down artwork-indexer artwork-redirect ssssss

# Compile static resources.
corepack enable
sudo -E -H -u musicbrainz yarn
sudo -E -H -u musicbrainz make -C po all_quiet deploy
NODE_ENV=test \
     WEBPACK_MODE=development \
     MUSICBRAINZ_RUNNING_TESTS=1 \
     NO_PROGRESS=1 \
     sudo -E -H -u musicbrainz carton exec -- ./script/compile_resources.sh default tests

# Add mbtest host alias to work around NO_PROXY restriction.
# See add_mbtest_alias.sh for details.
./docker/musicbrainz-tests/add_mbtest_alias.sh

sv_start_if_down template-renderer website

# Wait for plackup to start.
sleep 10

sudo -E -H -u musicbrainz mkdir -p junit_output

sudo -E -H -u musicbrainz carton exec -- \
     ./t/selenium.js --browser-binary-path=/opt/chrome-linux64/chrome \
     | tee >(./node_modules/.bin/tap-junit > ./junit_output/selenium.xml) \
     | ./node_modules/.bin/tap-difflet

# Stop the template-renderer so that it dumps coverage.
sv down template-renderer
sleep 10
sudo -E -H -u musicbrainz ./node_modules/.bin/nyc report --reporter=html

sudo -E -H -u musicbrainz mkdir -p svlog
for service in /var/log/service/*; do
     cp "$service"/current svlog/"$(basename "$service")".log
done
chown musicbrainz:musicbrainz svlog/*.log
