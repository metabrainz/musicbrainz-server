\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE cover_art_archive.release_group_cover_art
(
    release_group       INTEGER NOT NULL,
    release             INTEGER NOT NULL
);

COMMIT;
