BEGIN;

SET search_path = 'event_art_archive';

CREATE OR REPLACE FUNCTION materialize_eaa_presence() RETURNS trigger AS $$
    BEGIN
        -- On delete, set the presence flag to 'absent' if there's no more
        -- event art
        IF TG_OP = 'DELETE' THEN
            IF NOT EXISTS (
                SELECT TRUE FROM event_art_archive.event_art
                WHERE event = OLD.event
            ) THEN
                UPDATE musicbrainz.event_meta
                SET event_art_presence = 'absent'
                WHERE id = OLD.event;
            END IF;
        END IF;

        -- On insert, set the presence flag to 'present' if it was previously
        -- 'absent'
        IF TG_OP = 'INSERT' THEN
            CASE (
                SELECT event_art_presence FROM musicbrainz.event_meta
                WHERE id = NEW.event
            )
                WHEN 'absent' THEN
                    UPDATE musicbrainz.event_meta
                    SET event_art_presence = 'present'
                    WHERE id = NEW.event;
                WHEN 'darkened' THEN
                    RAISE EXCEPTION 'This event has been darkened and cannot have new event art';
                ELSE
            END CASE;
        END IF;

        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION resequence_positions(event_id INT) RETURNS void AS $$
    BEGIN
        UPDATE event_art_archive.event_art
        SET ordering = recalculated.row_number
        FROM (
            SELECT *,
              row_number() OVER (PARTITION BY event ORDER BY ordering ASC)
            FROM event_art_archive.event_art
            WHERE event_art.event = event_id
        ) recalculated
        WHERE recalculated.id = event_art.id AND
          recalculated.row_number != event_art.ordering;
   END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION resequence_event_art_trigger() RETURNS trigger AS $$
    BEGIN
        IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
            PERFORM event_art_archive.resequence_positions(NEW.event);
        END IF;

        IF (TG_OP = 'DELETE') OR
           (TG_OP = 'UPDATE' AND NEW.event != OLD.event)
        THEN
            PERFORM event_art_archive.resequence_positions(OLD.event);
        END IF;

        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

COMMIT;
