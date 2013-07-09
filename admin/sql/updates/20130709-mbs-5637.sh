#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Run this as
#
#    carton exec -Ilib -- admin/sql/updates/20130709-mbs-5637.sh
#

echo `date` : Fixing link table

# Uses default of 20 links at a time.
while ("$DIR/../../cleanup/FixLinkDuplicates"); do
    sleep 60m
done

echo `date` : Done.
