BEGIN;

CREATE SCHEMA cover_art_archive;
SET search_path = 'cover_art_archive';

CREATE TABLE art_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE cover_art (
    id BIGINT NOT NULL PRIMARY KEY,
    release INTEGER NOT NULL REFERENCES musicbrainz.release (id) ON DELETE CASCADE,
    comment TEXT NOT NULL DEFAULT '',
    edit INTEGER NOT NULL REFERENCES musicbrainz.edit (id),
    ordering INTEGER NOT NULL CHECK (ordering >= 0),
    date_uploaded TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

CREATE TABLE cover_art_type (
    id BIGINT NOT NULL REFERENCES cover_art (id) ON DELETE CASCADE,
    type_id INTEGER NOT NULL REFERENCES art_type (id),
    PRIMARY KEY (id, type_id)
);

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

CREATE TRIGGER update_release_coverart AFTER INSERT OR DELETE
ON cover_art_archive.cover_art
FOR EACH ROW EXECUTE PROCEDURE materialize_caa_presence();

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
            PERFORM resequence_positions(NEW.release);
        END IF;

        IF (TG_OP = 'DELETE') OR
           (TG_OP = 'UPDATE' AND NEW.release != OLD.release)
        THEN
            PERFORM resequence_positions(OLD.release);
        END IF;

        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER resquence_cover_art AFTER INSERT OR UPDATE OR DELETE
ON cover_art_archive.cover_art
FOR EACH ROW EXECUTE PROCEDURE resequence_cover_art_trigger();

COMMIT;
