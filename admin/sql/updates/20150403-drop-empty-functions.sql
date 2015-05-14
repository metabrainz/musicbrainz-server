\set ON_ERROR_STOP 1
BEGIN;

DROP FUNCTION IF EXISTS empty_artists();
DROP FUNCTION IF EXISTS empty_events();
DROP FUNCTION IF EXISTS empty_labels();
DROP FUNCTION IF EXISTS empty_places();
DROP FUNCTION IF EXISTS empty_release_groups();
DROP FUNCTION IF EXISTS empty_series();
DROP FUNCTION IF EXISTS empty_works();

COMMIT;
