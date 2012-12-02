-- Adjust this setting to control where the objects get created.
SET search_path = 'statistics','musicbrainz',public;

\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER "reptg_statistic"
AFTER INSERT OR DELETE OR UPDATE ON "statistic"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_statistic_event"
AFTER INSERT OR DELETE OR UPDATE ON "statistic_event"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

COMMIT;

-- vi: set ts=4 sw=4 et :
