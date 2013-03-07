#!/bin/bash

carton exec -Ilib -- script/create_test_db.sh
carton exec -Ilib -- admin/sql/updates/20130220-reduplicate-tracklists.pl
carton exec -Ilib -- admin/psql < admin/sql/updates/20130220-update-track-trigger.sql
carton exec -Ilib -- admin/psql < admin/sql/updates/20130221-add-track-gid.sql


