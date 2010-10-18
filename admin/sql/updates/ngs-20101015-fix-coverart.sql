\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE release_coverart ALTER COLUMN coverfetched DROP DEFAULT;

ALTER TABLE release_coverart DROP CONSTRAINT release_coverart_fk_id;

ALTER TABLE release_coverart
   ADD CONSTRAINT release_coverart_fk_id
   FOREIGN KEY (id)
   REFERENCES release(id)
   ON DELETE CASCADE;

INSERT INTO release_coverart (id)
    SELECT r.id 
    FROM release r
        LEFT JOIN release_coverart rc ON r.id = rc.id
    WHERE rc.id IS NULL;

COMMIT;
