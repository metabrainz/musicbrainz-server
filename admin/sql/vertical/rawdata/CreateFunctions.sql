\set ON_ERROR_STOP 1
BEGIN;

CREATE OR REPLACE FUNCTION delete_ratings(enttype TEXT, ids INTEGER[])
RETURNS TABLE(editor INT, rating SMALLINT) AS $$
DECLARE
    tablename TEXT;
BEGIN
    tablename = enttype || '_rating_raw';
    RETURN QUERY
       EXECUTE 'DELETE FROM ' || tablename || ' WHERE ' || enttype || ' = any($1)
                RETURNING editor, rating'
         USING ids;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------
-- Delete tags and return them for use in sub queries
-------------------------------------------------------------------
CREATE OR REPLACE FUNCTION delete_tags(enttype TEXT, ids INTEGER[])
RETURNS TABLE(editor INT, tag INT) AS $$
DECLARE
    tablename TEXT;
BEGIN
    tablename = enttype || '_tag_raw';
    RETURN QUERY
       EXECUTE 'DELETE FROM ' || tablename || ' WHERE ' || enttype || ' = any($1)
                RETURNING editor, tag'
         USING ids;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
