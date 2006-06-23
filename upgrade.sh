#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Upgrading to RELEASE-20060310-BRANCH

# This replication packet will have the old SCHEMA_SEQUENCE number

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
	# The old / new schema sequence numbers
	OLD_SEQ=$(( $DB_SCHEMA_SEQUENCE - 1 ))
	NEW_SEQ=$DB_SCHEMA_SEQUENCE
	# The final export of the old schema needs to run under the old sequence number
	perl -i -pwe 's/\b\d+\b/'$OLD_SEQ'/ if m/^sub DB_SCHEMA_SEQUENCE /' ./cgi-bin/DBDefs.pm
	./admin/RunExport
	perl -i -pwe 's/\b\d+\b/'$NEW_SEQ'/ if m/^sub DB_SCHEMA_SEQUENCE /' ./cgi-bin/DBDefs.pm
fi

echo `date` : Upgrading database
sh ./admin/sql/updates/20060310-1.sh

echo `date` : Going to schema sequence $DB_SCHEMA_SEQUENCE
echo "UPDATE replication_control SET current_schema_sequence = $DB_SCHEMA_SEQUENCE;" | ./admin/psql READWRITE

# We're now at the new schema, so the next replication packet (if we are
# the master) will have the new SCHEMA_SEQUENCE number; thus, it can only
# be applied to a new schema.

echo `date` : Done

# eof
