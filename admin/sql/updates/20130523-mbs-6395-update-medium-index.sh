#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Run this as
#
#    carton exec -Ilib -- admin/sql/updates/20130523-mbs-6395-update-medium-index.sh
#

echo `date` : Fixing medium_index table.

while ("$DIR/20130523-mbs-6395-update-medium-index.pl"); do
    sleep 60m
done

echo `date` : Done.



