#!/usr/bin/env bash

cd /home/musicbrainz/musicbrainz-server

rm /etc/service/{postgresql,redis}/down
sv start postgresql redis

# Wait for the database to start.
sleep 10

# Copy in DBDefs.pm, which is required before invoking create_test_db.sh.
sudo -E -H -u musicbrainz cp docker/musicbrainz-tests/DBDefs.pm lib/

# Create the musicbrainz_test and musicbrainz_selenium DBs.
sudo -E -H -u musicbrainz carton exec -- ./script/create_test_db.sh
sudo -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres \
     musicbrainz_selenium

# Set the open file limit Solr requests on startup, then start Solr.
ulimit -n 65000
rm /etc/service/solr/down && sv up solr

# Setup the rabbitmq user/vhost used by pg_amqp + sir.
service rabbitmq-server start
rabbitmqctl add_user sir sir
rabbitmqctl add_vhost /sir-test
rabbitmqctl set_permissions -p /sir-test sir '.*' '.*' '.*'

# Install the sir triggers into musicbrainz_selenium.
export SIR_DIR=/home/musicbrainz/sir
cd "$SIR_DIR"
sudo -E -H -u musicbrainz sh -c '. venv/bin/activate; python -m sir amqp_setup; python -m sir extension; python -m sir triggers --broker-id=1'
sudo -u postgres psql -U postgres -f sql/CreateExtension.sql musicbrainz_selenium
sudo -u postgres psql -U musicbrainz -f sql/CreateFunctions.sql musicbrainz_selenium
sudo -u postgres psql -U musicbrainz -f sql/CreateTriggers.sql musicbrainz_selenium
rm /etc/service/sir-queue-purger/down && sv start sir-queue-purger

cd /home/musicbrainz/musicbrainz-server

# Compile static resources.
sudo -E -H -u musicbrainz yarn
sudo -E -H -u musicbrainz make -C po all_quiet deploy
NODE_ENV=test WEBPACK_MODE=development \
     sudo -E -H -u musicbrainz carton exec -- ./script/compile_resources.sh

# Add mbtest host alias to work around NO_PROXY restriction.
# See add_mbtest_alias.sh for details.
./docker/musicbrainz-tests/add_mbtest_alias.sh

rm /etc/service/{template-renderer,website}/down
sv start template-renderer website

# Wait for plackup to start.
sleep 10

sudo -E -H -u musicbrainz mkdir -p junit_output

sudo -E -H -u musicbrainz carton exec -- ./t/selenium.js \
     | tee >(./node_modules/.bin/tap-junit > ./junit_output/selenium.xml) \
     | ./node_modules/.bin/tap-difflet

# Stop the template-renderer so that it dumps coverage.
sv down template-renderer
sleep 10
sudo -E -H -u musicbrainz ./node_modules/.bin/nyc report --reporter=html
