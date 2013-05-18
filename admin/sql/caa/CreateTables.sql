\set ON_ERROR_STOP 1

BEGIN;

SET search_path = 'cover_art_archive';

CREATE TABLE art_type (
    id SERIAL NOT NULL, -- PK
    name TEXT NOT NULL
);

CREATE TABLE image_type (
    mime_type TEXT NOT NULL, -- PK
    suffix TEXT NOT NULL
);

CREATE TABLE cover_art (
    id BIGINT NOT NULL, -- PK
    release INTEGER NOT NULL, -- references musicbrainz.release.id CASCADE
    comment TEXT NOT NULL DEFAULT '',
    edit INTEGER NOT NULL, -- references musicbrainz.edit.id
    ordering INTEGER NOT NULL CHECK (ordering > 0),
    date_uploaded TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    edits_pending INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    mime_type TEXT NOT NULL  -- references cover_art_archive.image_type.mime_type
);

CREATE TABLE cover_art_type (
    id BIGINT NOT NULL, -- PK, references cover_art_archive.cover_art.id CASCADE,
    type_id INTEGER NOT NULL -- PK, references cover_art_archive.art_type.id,
);

CREATE TABLE release_group_cover_art
(
    release_group       INTEGER NOT NULL, -- PK, references musicbrainz.release_group.id
    release             INTEGER NOT NULL  -- FK, references musicbrainz.release.id
);

COMMIT;
