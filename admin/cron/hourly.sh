#!/bin/sh

cd ..

# Hmmm, ugly.  Alternatively, just add a crontab entry like so:
# 0 * * * * MAILTO="rob@eorbit.net,djce@musicbrainz.org" ./CheckVotes.pl
ADMINS="rob@eorbit.net djce@musicbrainz.org"

OUTPUT=`./CheckVotes.pl 2>&1 | grep -v ^DELETE`
[ "$OUTPUT" == "" ] || ( echo "$OUTPUT" | mail -s "ModBot output" $ADMINS )

./RemoveOldSessions > /dev/null
