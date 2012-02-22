BEGIN;

CREATE SCHEMA cover_art_archive;
SET search_path = 'cover_art_archive';

CREATE TABLE art_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE cover_art (
    id SERIAL NOT NULL PRIMARY KEY,
    release INTEGER NOT NULL REFERENCES musicbrainz.release (id) ON DELETE CASCADE,
    comment TEXT NOT NULL DEFAULT '',
    edit INTEGER NOT NULL REFERENCES musicbrainz.edit (id),
    ordering INTEGER NOT NULL CHECK (ordering > 0),
    url TEXT NOT NULL
);

CREATE TABLE cover_art_type (
    id INTEGER NOT NULL REFERENCES cover_art (id) ON DELETE CASCADE,
    type_id INTEGER NOT NULL REFERENCES art_type (id),
    PRIMARY KEY (id, type_id)
);

CREATE TABLE release (
    release INTEGER NOT NULL REFERENCES musicbrainz.release (id) ON DELETE CASCADE PRIMARY KEY,
    front_image INTEGER REFERENCES cover_art (id),
    back_image INTEGER REFERENCES cover_art (id)
);

COMMIT;
