-- Abstract: Create raw tag tables

\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE artist_tag_raw
(
    artist              INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL
);

CREATE TABLE release_tag_raw
(
    release             INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL
);

CREATE TABLE track_tag_raw
(
    track               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL
);

CREATE TABLE label_tag_raw
(
    label               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL
);

-- primary keys

ALTER TABLE artist_tag_raw ADD CONSTRAINT artist_tag_raw_pkey PRIMARY KEY (artist, tag, moderator);
ALTER TABLE release_tag_raw ADD CONSTRAINT release_tag_raw_pkey PRIMARY KEY (release, tag, moderator);
ALTER TABLE track_tag_raw ADD CONSTRAINT track_tag_raw_pkey PRIMARY KEY (track, tag, moderator);
ALTER TABLE label_tag_raw ADD CONSTRAINT label_tag_raw_pkey PRIMARY KEY (label, tag, moderator);

-- indexes
CREATE INDEX artist_tag_raw_idx_artist ON artist_tag_raw (artist);
CREATE INDEX artist_tag_raw_idx_tag ON artist_tag_raw (tag);
CREATE INDEX artist_tag_raw_idx_moderator ON artist_tag_raw (moderator);

CREATE INDEX release_tag_raw_idx_release ON release_tag_raw (release);
CREATE INDEX release_tag_raw_idx_tag ON release_tag_raw (tag);
CREATE INDEX release_tag_raw_idx_moderator ON release_tag_raw (moderator);

CREATE INDEX track_tag_raw_idx_track ON track_tag_raw (track);
CREATE INDEX track_tag_raw_idx_tag ON track_tag_raw (tag);
CREATE INDEX track_tag_raw_idx_moderator ON track_tag_raw (moderator);

CREATE INDEX label_tag_raw_idx_label ON label_tag_raw (label);
CREATE INDEX label_tag_raw_idx_tag ON label_tag_raw (tag);
CREATE INDEX label_tag_raw_idx_moderator ON label_tag_raw (moderator);

COMMIT;

-- vi: set ts=8 sw=8 et tw=0 :
