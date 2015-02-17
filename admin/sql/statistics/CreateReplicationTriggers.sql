-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'statistics', musicbrainz, public;

BEGIN;

CREATE TRIGGER "reptg_statistic"
AFTER INSERT OR DELETE OR UPDATE ON "statistic"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_statistic_event"
AFTER INSERT OR DELETE OR UPDATE ON "statistic_event"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

COMMIT;
