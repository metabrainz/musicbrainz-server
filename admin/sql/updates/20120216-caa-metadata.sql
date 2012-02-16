BEGIN;

CREATE SCHEMA cover_art_archive;
SET search_path = 'cover_art_archive';

CREATE TABLE art_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE cover_art (
    id INTEGER NOT NULL PRIMARY KEY,
    comment TEXT NOT NULL DEFAULT '',
    edit INTEGER NOT NULL REFERENCES musicbrainz.edit (id),
    ordering INTEGER NOT NULL CHECK (ordering > 0),
    url TEXT NOT NULL
);

CREATE TABLE cover_art_type (
    id INTEGER NOT NULL REFERENCES cover_art (id),
    type_id INTEGER NOT NULL REFERENCES art_type (id),
    PRIMARY KEY (id, type_id)
);

CREATE TABLE release (
    id INTEGER NOT NULL REFERENCES musicbrainz.release (id) PRIMARY KEY,
    front_image INTEGER REFERENCES cover_art (id),
    back_image INTEGER REFERENCES cover_art (id)
);

COMMIT;
