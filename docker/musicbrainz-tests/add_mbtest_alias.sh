#!/usr/bin/env bash

# As noted in docker/musicbrainz-tests/DBDefs.pm, CircleCI
# sets NO_PROXY=127.0.0.1,localhost in every container, so
# the Selenium proxy doesn't work unless we make requests
# against a different hostname alias. We use mbtest, added
# to /etc/hosts here and in the selenium job below.

echo '127.0.0.1 mbtest' >> /etc/hosts

# For BETA_REDIRECT_HOSTNAME
echo '127.0.0.1 mbtest-beta' >> /etc/hosts
