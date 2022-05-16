\set ON_ERROR_STOP 1

BEGIN;

DO $$
BEGIN
  PERFORM 1 FROM pg_matviews
  WHERE schemaname = 'dbmirror2'
  AND matviewname = 'column_info';

  IF FOUND THEN
    REFRESH MATERIALIZED VIEW dbmirror2.column_info;
  END IF;
END $$;

COMMIT;
