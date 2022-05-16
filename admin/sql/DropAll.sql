\unset ON_ERROR_STOP

-- This script is a really quick and dirty way to tear down a database.
-- It's really just a debug / development tool.

\i admin/sql/DropReplicationTriggers.sql
\i admin/sql/DropTriggers.sql
\i admin/sql/DropMirrorOnlyTriggers.sql
\i admin/sql/DropFunctions.sql
\i admin/sql/DropViews.sql
\i admin/sql/DropFKConstraints.sql
\i admin/sql/DropIndexes.sql
\i admin/sql/DropPrimaryKeys.sql
\i admin/sql/DropTables.sql
\i admin/sql/DropTypes.sql
\i admin/sql/DropCollations.sql
