-- Abstract: Create tag tables

-- TODO:
-- 1. Push these changes to CreateTables.sql
-- 2. Consider replication triggers on non-raw tables

\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE tag
(
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    refcount            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE artist_tag
(
    artist              INTEGER NOT NULL,
    tag                 INTEGER NOT NULL
);

CREATE TABLE release_tag
(
    release             INTEGER NOT NULL,
    tag                 INTEGER NOT NULL
);

CREATE TABLE track_tag
(
    track               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL
);

CREATE TABLE label_tag
(
    label               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL
);

-- These tables could/will live on a separate server, so no FKs to the main tables

CREATE TABLE artist_tag_raw
(
    artist              INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL,
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release_tag_raw
(
    release             INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL,
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE track_tag_raw
(
    track               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL,
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE label_tag_raw
(
    label               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    moderator           INTEGER NOT NULL,
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- primary keys
ALTER TABLE tag ADD CONSTRAINT tag_pkey PRIMARY KEY (id);

ALTER TABLE artist_tag ADD CONSTRAINT artist_tag_pkey PRIMARY KEY (artist, tag);
ALTER TABLE release_tag ADD CONSTRAINT release_tag_pkey PRIMARY KEY (release, tag);
ALTER TABLE track_tag ADD CONSTRAINT track_tag_pkey PRIMARY KEY (track, tag);
ALTER TABLE label_tag ADD CONSTRAINT label_tag_pkey PRIMARY KEY (label, tag);

ALTER TABLE artist_tag_raw ADD CONSTRAINT artist_tag_raw_pkey PRIMARY KEY (artist, tag, moderator);
ALTER TABLE release_tag_raw ADD CONSTRAINT release_tag_raw_pkey PRIMARY KEY (release, tag, moderator);
ALTER TABLE track_tag_raw ADD CONSTRAINT track_tag_raw_pkey PRIMARY KEY (track, tag, moderator);
ALTER TABLE label_tag_raw ADD CONSTRAINT label_tag_raw_pkey PRIMARY KEY (label, tag, moderator);

-- indexes
CREATE UNIQUE INDEX tag_idx_name ON tag (name);

CREATE UNIQUE INDEX artist_tag_idx_artist ON artist_tag (artist);
CREATE UNIQUE INDEX artist_tag_idx_tag ON artist_tag (tag);
CREATE UNIQUE INDEX release_tag_idx_release ON release_tag (release);
CREATE UNIQUE INDEX release_tag_idx_tag ON release_tag (tag);
CREATE UNIQUE INDEX track_tag_idx_track ON track_tag (track);
CREATE UNIQUE INDEX track_tag_idx_tag ON track_tag (tag);
CREATE UNIQUE INDEX label_tag_idx_label ON label_tag (label);
CREATE UNIQUE INDEX label_tag_idx_tag ON label_tag (tag);

CREATE UNIQUE INDEX artist_tag_raw_idx_artist ON artist_tag_raw (artist);
CREATE UNIQUE INDEX artist_tag_raw_idx_tag ON artist_tag_raw (tag);
CREATE UNIQUE INDEX artist_tag_raw_idx_moderator ON artist_tag_raw (moderator);
CREATE UNIQUE INDEX artist_tag_raw_idx_created ON artist_tag_raw (created);

CREATE UNIQUE INDEX release_tag_raw_idx_release ON release_tag_raw (release);
CREATE UNIQUE INDEX release_tag_raw_idx_tag ON release_tag_raw (tag);
CREATE UNIQUE INDEX release_tag_raw_idx_moderator ON release_tag_raw (moderator);
CREATE UNIQUE INDEX release_tag_raw_idx_created ON release_tag_raw (created);

CREATE UNIQUE INDEX track_tag_raw_idx_track ON track_tag_raw (track);
CREATE UNIQUE INDEX track_tag_raw_idx_tag ON track_tag_raw (tag);
CREATE UNIQUE INDEX track_tag_raw_idx_moderator ON track_tag_raw (moderator);
CREATE UNIQUE INDEX track_tag_raw_idx_created ON track_tag_raw (created);

CREATE UNIQUE INDEX label_tag_raw_idx_label ON label_tag_raw (label);
CREATE UNIQUE INDEX label_tag_raw_idx_tag ON label_tag_raw (tag);
CREATE UNIQUE INDEX label_tag_raw_idx_moderator ON label_tag_raw (moderator);
CREATE UNIQUE INDEX label_tag_raw_idx_created ON label_tag_raw (created);

-- foreign keys
ALTER TABLE artist_tag
    ADD CONSTRAINT fk_artist_tag_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE artist_tag
    ADD CONSTRAINT fk_artist_tag_tag
    FOREIGN KEY (tag)
    REFERENCES tag(id);

ALTER TABLE release_tag
    ADD CONSTRAINT fk_release_tag_release
    FOREIGN KEY (release)
    REFERENCES album(id);

ALTER TABLE release_tag
    ADD CONSTRAINT fk_release_tag_tag
    FOREIGN KEY (tag)
    REFERENCES tag(id);

ALTER TABLE track_tag
    ADD CONSTRAINT fk_track_tag_track
    FOREIGN KEY (track)
    REFERENCES track(id);

ALTER TABLE track_tag
    ADD CONSTRAINT fk_track_tag_tag
    FOREIGN KEY (tag)
    REFERENCES tag(id);

ALTER TABLE label_tag
    ADD CONSTRAINT fk_label_tag_track
    FOREIGN KEY (label)
    REFERENCES label(id);

ALTER TABLE label_tag
    ADD CONSTRAINT fk_label_tag_tag
    FOREIGN KEY (tag)
    REFERENCES tag(id);

COMMIT;

-- vi: set ts=8 sw=8 et tw=0 :
