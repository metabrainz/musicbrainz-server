\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE artist_noindex (
    artist INTEGER NOT NULL
);

ALTER TABLE artist_noindex
    ADD CONSTRAINT artist_noindex_pkey PRIMARY KEY (artist);

COMMIT;
