BEGIN;

SET search_path = 'cover_art_archive';

CREATE OR REPLACE FUNCTION caa_move() RETURNS trigger AS $$
    BEGIN
        IF OLD.release != NEW.release THEN
            PERFORM pgq.insert_event('CoverArtIndex', 'move',
                      (SELECT ca.id || E'\n' ||
                              old_release.gid || E'\n' ||
                              new_release.gid || E'\n' ||
                              it.suffix || E'\n'
                       FROM cover_art_archive.cover_art ca,
                         musicbrainz.release old_release,
                         musicbrainz.release new_release
                       JOIN cover_art_archive.image_type it USING (mime_type)
                       WHERE ca.id = OLD.id
                       AND old_release.id = OLD.release
                       AND new_release.id = NEW.release));
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION delete_release() RETURNS trigger AS $$
    BEGIN
        PERFORM
          pgq.insert_event('CoverArtIndex', 'delete',
            (cover_art.id || E'\n' ||
             OLD.gid || E'\n' || image_type.suffix)::text)
        FROM cover_art_archive.cover_art
        JOIN cover_art_archive.image_type USING (mime_type)
        WHERE release = OLD.id;

        PERFORM pgq.insert_event('CoverArtIndex', 'delete',
            ('index.json' || E'\n' || OLD.gid)::text)
        FROM musicbrainz.release
        WHERE release.id = OLD.id;

        RETURN OLD;
    END;
$$ LANGUAGE 'plpgsql';

COMMIT;