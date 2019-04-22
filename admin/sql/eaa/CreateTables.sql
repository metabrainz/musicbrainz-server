\set ON_ERROR_STOP 1

BEGIN;

SET search_path = 'event_art_archive';

CREATE TABLE art_type ( -- replicate (verbose)
    id                  SERIAL NOT NULL, -- PK
    name                TEXT NOT NULL,
    parent              INTEGER, -- references event_art_archive.art_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

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

COMMIT;
