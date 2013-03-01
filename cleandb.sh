#!/bin/bash

carton exec -Ilib -- script/create_test_db.sh
carton exec -Ilib -- admin/sql/updates/20130220-reduplicate-tracklists.pl
carton exec -Ilib -- admin/psql < admin/sql/updates/20130220-update-track-trigger.sql
carton exec -Ilib -- admin/psql < admin/sql/updates/20130221-add-track-gid.sql
echo "DELETE FROM release_group_primary_type;" | carton exec -Ilib -- admin/psql
echo "DELETE FROM release_status;" | carton exec -Ilib -- admin/psql
cp t/sql/webservice.trackids.sql t/sql/webservice.sql

