-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'wikidocs', musicbrainz, public;

BEGIN;

CREATE TRIGGER reptg2_wikidocs_index
AFTER INSERT OR DELETE OR UPDATE ON wikidocs_index
FOR EACH ROW EXECUTE PROCEDURE dbmirror2.recordchange();

COMMIT;
