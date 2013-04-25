-- Adjust this setting to control where the objects get created.
SET search_path = 'wikidocs','musicbrainz',public;

\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER "reptg_wikidocs_index"
AFTER INSERT OR DELETE OR UPDATE ON "wikidocs_index"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

COMMIT;

-- vi: set ts=4 sw=4 et :
