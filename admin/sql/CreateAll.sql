\set ON_ERROR_STOP 1

-- This script is the really quick and dirty way to set up a database
-- (although it will contain no data - you might want to run
-- admin/sql/InsertDefaultRows.sql too).  It's really just a debug /
-- development tool.  If you want to import a dataset, use "InitDb.pl"
-- instead.

\i admin/sql/CreateTables.sql
\i admin/sql/CreatePrimaryKeys.sql
\i admin/sql/CreateIndexes.sql
\i admin/sql/CreateFKConstraints.sql
\i admin/sql/CreateViews.sql
\i admin/sql/CreateFunctions.sql
\i admin/sql/CreateTriggers.sql
\i admin/sql/CreateReplicationTriggers.sql
