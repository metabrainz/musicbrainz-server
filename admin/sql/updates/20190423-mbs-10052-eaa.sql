\set ON_ERROR_STOP 1
BEGIN;

CREATE SCHEMA event_art_archive;

SET search_path = event_art_archive, musicbrainz;

CREATE TYPE musicbrainz.event_art_presence AS ENUM ('absent', 'present', 'darkened');

ALTER TABLE musicbrainz.event_meta
ADD COLUMN event_art_presence musicbrainz.event_art_presence NOT NULL DEFAULT 'absent';

-- Tables

CREATE TABLE art_type ( -- replicate (verbose)
    id                  SERIAL NOT NULL, -- PK
    name                TEXT NOT NULL,
    parent              INTEGER, -- references event_art_archive.art_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

INSERT INTO art_type VALUES
    (1, 'Poster', NULL, 0, NULL, generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'even_art_archive.art_type' || 1));

CREATE TABLE event_art ( -- replicate (verbose)
    id BIGINT NOT NULL, -- PK
    event INTEGER NOT NULL, -- references musicbrainz.event.id CASCADE
    comment TEXT NOT NULL DEFAULT '',
    edit INTEGER NOT NULL, -- separately references musicbrainz.edit.id
    ordering INTEGER NOT NULL CHECK (ordering > 0),
    date_uploaded TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    edits_pending INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    mime_type TEXT NOT NULL, -- references cover_art_archive.image_type.mime_type
    filesize INTEGER,
    thumb_250_filesize INTEGER,
    thumb_500_filesize INTEGER,
    thumb_1200_filesize INTEGER
);

CREATE TABLE event_art_type ( -- replicate (verbose)
    id BIGINT NOT NULL, -- PK, references event_art_archive.event_art.id CASCADE,
    type_id INTEGER NOT NULL -- PK, references event_art_archive.art_type.id,
);

-- Primary keys

ALTER TABLE art_type ADD CONSTRAINT art_type_pkey PRIMARY KEY (id);
ALTER TABLE event_art ADD CONSTRAINT event_art_pkey PRIMARY KEY (id);
ALTER TABLE event_art_type ADD CONSTRAINT event_art_type_pkey PRIMARY KEY (id, type_id);

-- Indexes

CREATE INDEX event_art_idx_event ON event_art (event);
CREATE UNIQUE INDEX art_type_idx_gid ON art_type (gid);

-- Functions

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

-- Views

CREATE OR REPLACE VIEW index_listing AS
SELECT event_art.*,
  (edit.close_time IS NOT NULL) AS approved,
  coalesce(event_art.id = (SELECT id FROM event_art_archive.event_art_type
                   JOIN event_art_archive.event_art ea_front USING (id)
                   WHERE ea_front.event = event_art.event
                   AND type_id = 1
                   AND mime_type != 'application/pdf'
                   ORDER BY ea_front.ordering
                   LIMIT 1), FALSE) AS is_front,
  array(SELECT art_type.name
        FROM event_art_archive.event_art_type
        JOIN event_art_archive.art_type ON event_art_type.type_id = art_type.id
        WHERE event_art_type.id = event_art.id) AS types
FROM event_art_archive.event_art
LEFT JOIN musicbrainz.edit ON edit.id = event_art.edit;

COMMIT;
