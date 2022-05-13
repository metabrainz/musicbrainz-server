\set ON_ERROR_STOP 1

BEGIN;

-- Redefined to remove `INSERT INTO release_coverart (id) VALUES (NEW.id);`.
CREATE OR REPLACE FUNCTION a_ins_release() RETURNS trigger AS $$
BEGIN
    -- increment ref_count of the name
    PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    -- increment release_count of the parent release group
    UPDATE release_group_meta SET release_count = release_count + 1 WHERE id = NEW.release_group;
    -- add new release_meta
    INSERT INTO release_meta (id) VALUES (NEW.id);
    INSERT INTO artist_release_pending_update VALUES (NEW.id);
    INSERT INTO artist_release_group_pending_update VALUES (NEW.release_group);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

DROP TABLE release_coverart;

ALTER TABLE release_meta DROP COLUMN amazon_store;

COMMIT;
