\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor_oauth_token DROP COLUMN mac_key, DROP COLUMN mac_time_diff;

COMMIT;
