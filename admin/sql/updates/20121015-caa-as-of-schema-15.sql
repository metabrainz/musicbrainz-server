BEGIN;

SET search_path = 'cover_art_archive';

CREATE TABLE art_type (
    id SERIAL NOT NULL, -- PK
    name TEXT NOT NULL
);

CREATE TABLE cover_art (
    id BIGINT NOT NULL, -- PK
    release INTEGER NOT NULL, -- references musicbrainz.release.id CASCADE
    comment TEXT NOT NULL DEFAULT '',
    edit INTEGER NOT NULL, -- references musicbrainz.edit.id
    ordering INTEGER NOT NULL CHECK (ordering > 0),
    date_uploaded TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

CREATE TABLE cover_art_type (
    id BIGINT NOT NULL, -- PK, references cover_art_archive.cover_art.id CASCADE,
    type_id INTEGER NOT NULL -- PK, references art_type.id,
);

COMMIT;
