#!/bin/sh

cd ..
./CheckVotes.pl "rob@eorbit.net djce" 2>&1 | grep 'Sent mail'
./RemoveOldSessions > /dev/null
