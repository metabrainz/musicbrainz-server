#!/usr/bin/env bash

set -u

if [[ -t 1 ]]
then
    exec 2>&1 | ts '%X %Z'
fi

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

./admin/RunSampleDataDump

# This script has been disabled in production ever since accounts were
# moved to MetaBrainz, as the checks it performs are inadequate: it doesn't
# look for any applications/OAuth tokens in the MetaBrainz DB. Presumably
# this script should be ported to the MetaBrainz repository in some form in
# the future; account deletions performed there are synced to MusicBrainz
# via webhooks.
#./admin/RemoveEmptyAccounts.pl

echo Monthly jobs complete!
