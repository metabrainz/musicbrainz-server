BEGIN;

SET search_path = 'cover_art_archive';

CREATE OR REPLACE FUNCTION materialize_caa_presence() RETURNS trigger AS $$
    BEGIN
        -- On delete, set the presence flag to 'absent' if there's no more
        -- cover art
        IF TG_OP = 'DELETE' THEN
            IF NOT EXISTS (
                SELECT TRUE FROM cover_art_archive.cover_art
                WHERE release = OLD.release
            ) THEN
                UPDATE musicbrainz.release_meta
                SET cover_art_presence = 'absent'
                WHERE id = OLD.release;
            END IF;
        END IF;

        -- On insert, set the presence flag to 'present' if it was previously
        -- 'absent'
        IF TG_OP = 'INSERT' THEN
            CASE (
                SELECT cover_art_presence FROM musicbrainz.release_meta
                WHERE id = NEW.release
            )
                WHEN 'absent' THEN
                    UPDATE musicbrainz.release_meta
                    SET cover_art_presence = 'present'
                    WHERE id = NEW.release;
                WHEN 'darkened' THEN
                    RAISE EXCEPTION 'This release has been darkened and cannot have new cover art';
                ELSE
            END CASE;
        END IF;

        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION resequence_positions(release_id INT) RETURNS void AS $$
    BEGIN
        UPDATE cover_art_archive.cover_art
        SET ordering = recalculated.row_number
        FROM (
            SELECT *,
              row_number() OVER (PARTITION BY release ORDER BY ordering ASC)
            FROM cover_art_archive.cover_art
            WHERE cover_art.release = release_id
        ) recalculated
        WHERE recalculated.id = cover_art.id AND
          recalculated.row_number != cover_art.ordering;
   END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION resequence_cover_art_trigger() RETURNS trigger AS $$
    BEGIN
        IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
            PERFORM cover_art_archive.resequence_positions(NEW.release);
        END IF;

        IF (TG_OP = 'DELETE') OR
           (TG_OP = 'UPDATE' AND NEW.release != OLD.release)
        THEN
            PERFORM cover_art_archive.resequence_positions(OLD.release);
        END IF;

        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

COMMIT;
