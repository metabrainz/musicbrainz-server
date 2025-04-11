#!/usr/bin/env bash

# The mbtest hostname is added for the Selenium proxy in t/selenium.mjs:
#  * Browsers restrict using localhost as a proxy endpoint by default for
#    security reasons.
#  * Our tests previously ran in an environment where
#    `NO_PROXY=127.0.0.1,localhost` was forcefully set inside the container.
#    (This doesn't seem to be the case on GitHub Actions, but the above
#    point still holds.)
echo '127.0.0.1 mbtest' >> /etc/hosts

# For BETA_REDIRECT_HOSTNAME
echo '127.0.0.1 mbtest-beta' >> /etc/hosts
