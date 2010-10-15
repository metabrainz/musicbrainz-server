\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE release_coverart ALTER COLUMN coverfetched DROP DEFAULT;

INSERT INTO release_coverart (id)
    SELECT r.id 
    FROM release r
        LEFT JOIN release_coverart rc ON r.id = rc.id
    WHERE rc.id IS NULL;

COMMIT;
