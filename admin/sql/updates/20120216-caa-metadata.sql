BEGIN;

CREATE SCHEMA cover_art_archive;
SET search_path = 'cover_art_archive';

CREATE TABLE art_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE cover_art (
    release INTEGER NOT NULL REFERENCES musicbrainz.release (id) ON DELETE CASCADE,
    comment TEXT NOT NULL DEFAULT '',
    edit INTEGER NOT NULL REFERENCES musicbrainz.edit (id),
    ordering INTEGER NOT NULL CHECK (ordering > 0),
    url TEXT NOT NULL PRIMARY KEY,
    is_front BOOLEAN NOT NULL DEFAULT FALSE,
    is_back BOOLEAN NOT NULL DEFAULT FALSE,
    date_uploaded TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

CREATE UNIQUE INDEX cover_art_unique_front_constraint ON cover_art (release, is_front) WHERE is_front;
CREATE UNIQUE INDEX cover_art_unique_back_constraint ON cover_art (release, is_back) WHERE is_back;

CREATE TABLE cover_art_type (
    id INTEGER NOT NULL REFERENCES cover_art (id) ON DELETE CASCADE,
    type_id INTEGER NOT NULL REFERENCES art_type (id),
    PRIMARY KEY (id, type_id)
);

COMMIT;
