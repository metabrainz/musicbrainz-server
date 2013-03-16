#!/bin/bash

carton exec -Ilib -- script/create_test_db.sh READWRITE
carton exec -Ilib -- admin/sql/updates/20130220-reduplicate-tracklists-part1.pl
carton exec -Ilib -- admin/psql < admin/sql/updates/20130220-reduplicate-tracklists-part2.sql
carton exec -Ilib -- admin/psql < admin/sql/updates/20130220-update-track-trigger.sql
carton exec -Ilib -- admin/psql < admin/sql/updates/20130221-add-track-gid.sql
carton exec -Ilib -- admin/psql < admin/sql/updates/20130305-update-medium-track-count.sql
