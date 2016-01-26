#!/bin/sh

# This script is currently broken. Presumably it needs updating for all
# the entities added in MBS-7551. Once it's fixed, it can be re-added to
# daily.sh.

DIR=`dirname $0`
$DIR/psql READWRITE <$DIR/sql/CalculateRelatedTags.sql
