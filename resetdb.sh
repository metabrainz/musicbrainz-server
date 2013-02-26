#!/bin/bash

git checkout t/sql/webservice.sql
carton exec -Ilib -- script/setup_development_db.pl --destroy-all-the-things
carton exec -Ilib -- admin/sql/updates/20130220-reduplicate-tracklists.pl
carton exec -Ilib -- admin/psql < admin/sql/updates/20130220-update-track-trigger.sql
carton exec -Ilib -- admin/psql < admin/sql/updates/20130221-add-track-gid.sql

echo "To dump a webservice.sql:"
echo ""
echo "    carton exec -Ilib -- perl script/webservice_test_data.pl"
echo ""
