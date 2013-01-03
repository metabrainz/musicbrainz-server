BEGIN;

SET search_path = 'cover_art_archive';

SELECT pgq.create_queue('CoverArtIndex');
SELECT pgq.register_consumer('CoverArtIndex', 'CoverArtIndexer');

CREATE OR REPLACE FUNCTION reindex_release() RETURNS trigger AS $$
    DECLARE
        release_mbid UUID;
    BEGIN
        SELECT gid INTO release_mbid
        FROM musicbrainz.release r
        JOIN cover_art_archive.cover_art caa_r ON r.id = caa_r.release
        WHERE r.id = NEW.id;

        IF FOUND THEN
            PERFORM pgq.insert_event('CoverArtIndex', 'index', release_mbid::text);
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER caa_reindex AFTER UPDATE OR INSERT
ON musicbrainz.release FOR EACH ROW
EXECUTE PROCEDURE reindex_release();

CREATE OR REPLACE FUNCTION reindex_artist() RETURNS trigger AS $$
    BEGIN
        -- Short circuit if the name hasn't changed
        IF NEW.name = OLD.name AND NEW.sort_name = OLD.sort_name THEN
            RETURN NULL;
        END IF;

        PERFORM pgq.insert_event('CoverArtIndex', 'index', r.gid::text)
        FROM musicbrainz.release r
        JOIN cover_art_archive.cover_art caa_r ON r.id = caa_r.release
        JOIN musicbrainz.artist_credit_name acn ON r.artist_credit = acn.artist_credit
        WHERE acn.artist = NEW.id;

        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER caa_reindex AFTER UPDATE
ON musicbrainz.artist FOR EACH ROW
EXECUTE PROCEDURE reindex_artist();

CREATE OR REPLACE FUNCTION reindex_release_via_catno() RETURNS trigger AS $$
    DECLARE
        release_mbid UUID;
    BEGIN
        SELECT gid INTO release_mbid
        FROM musicbrainz.release
        JOIN musicbrainz.release_label ON release_label.release = release.id
        JOIN cover_art_archive.cover_art caa_r ON release.id = caa_r.release
        WHERE release.id = NEW.release;

        IF FOUND THEN
            PERFORM pgq.insert_event('CoverArtIndex', 'index', release_mbid::text);
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER caa_reindex AFTER UPDATE OR INSERT
ON musicbrainz.release_label FOR EACH ROW
EXECUTE PROCEDURE reindex_release_via_catno();

CREATE OR REPLACE FUNCTION reindex_caa() RETURNS trigger AS $$
    BEGIN
        IF TG_OP = 'DELETE' THEN
            PERFORM pgq.insert_event('CoverArtIndex', 'index',
                     (SELECT gid FROM musicbrainz.release
                      WHERE id = coalesce(OLD.release))::text);
        ELSE
            PERFORM pgq.insert_event('CoverArtIndex', 'index',
                     (SELECT gid FROM musicbrainz.release
                      WHERE id = coalesce(NEW.release))::text);
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER caa_reindex AFTER UPDATE OR INSERT OR DELETE
ON cover_art_archive.cover_art FOR EACH ROW
EXECUTE PROCEDURE reindex_caa();

CREATE OR REPLACE FUNCTION caa_move() RETURNS trigger AS $$
    BEGIN
        IF OLD.release != NEW.release THEN
            PERFORM pgq.insert_event('CoverArtIndex', 'move',
                      (SELECT ca.id || E'\n' ||
                              old_release.gid || E'\n' ||
                              new_release.gid || E'\n'
                       FROM cover_art_archive.cover_art ca,
                         musicbrainz.release old_release,
                         musicbrainz.release new_release
                       WHERE ca.id = OLD.id
                       AND old_release.id = OLD.release
                       AND new_release.id = NEW.release));
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER caa_move BEFORE UPDATE
ON cover_art_archive.cover_art FOR EACH ROW
EXECUTE PROCEDURE caa_move();

CREATE OR REPLACE FUNCTION delete_release() RETURNS trigger AS $$
    BEGIN
        PERFORM
          pgq.insert_event('CoverArtIndex', 'delete',
            (cover_art.id || E'\n' || OLD.gid)::text)
        FROM cover_art_archive.cover_art
        WHERE release = OLD.id;

        PERFORM pgq.insert_event('CoverArtIndex', 'delete',
            ('index.json' || E'\n' || OLD.gid)::text)
        FROM musicbrainz.release
        WHERE release.id = OLD.id;

        RETURN OLD;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER caa_delete BEFORE DELETE
ON musicbrainz.release FOR EACH ROW
EXECUTE PROCEDURE delete_release();

COMMIT;
