#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Adding constraints for ISRCs and ISWCs
./admin/psql READWRITE < admin/sql/updates/20110718-isrc-validation.sql

echo `date` : Removing entirely orphaned recordings
./admin/psql READWRITE < admin/sql/updates/20110721-orphaned-recordings.sql

echo `date` : Adding label code constraints
./admin/psql READWRITE < admin/sql/updates/20110801-label-code-validation.sql

echo `date` : Fixing edits_failed column
./admin/psql READWRITE < admin/sql/updates/20110725-rebuild-editor-stats.sql

echo `date` : Done

# eof
