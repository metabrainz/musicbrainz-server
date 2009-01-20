\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE cdtoc_raw
(
    id                  SERIAL,
    release             INTEGER NOT NULL, -- references release_raw
    discid              CHAR(28) NOT NULL,
    trackcount          INTEGER NOT NULL,
    leadoutoffset       INTEGER NOT NULL,
    trackoffset         INTEGER[] NOT NULL
);

CREATE TABLE release_raw
(
    id                  SERIAL,
    title               VARCHAR(255) NOT NULL,
    artist              VARCHAR(255),
    added               TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    lastmodified        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    lookupcount         INTEGER DEFAULT 0,
    modifycount         INTEGER DEFAULT 0,
    source		INTEGER DEFAULT 0,
    barcode             VARCHAR(255),
    comment             VARCHAR(255)
);

CREATE TABLE track_raw
(
    id                  SERIAL,
    release             INTEGER NOT NULL,      -- references release_raw
    title               VARCHAR(255) NOT NULL,
    artist              VARCHAR(255),          -- For VA albums, otherwise empty
    sequence            INTEGER NOT NULL
);

ALTER TABLE cdtoc_raw ADD CONSTRAINT cdtoc_raw_pkey PRIMARY KEY (id);
ALTER TABLE release_raw ADD CONSTRAINT release_raw_pkey PRIMARY KEY (id);
ALTER TABLE track_raw ADD CONSTRAINT track_raw_pkey PRIMARY KEY (id);

CREATE INDEX track_raw_idx_release ON track_raw (release);
CREATE INDEX cdtoc_raw_idx_discid ON cdtoc_raw (discid);
CREATE INDEX cdtoc_raw_idx_trackoffset ON cdtoc_raw (trackoffset);
CREATE UNIQUE INDEX cdtoc_raw_idx_toc ON cdtoc_raw (trackcount, leadoutoffset, trackoffset);

CREATE INDEX release_raw_idx_lastmodified ON release_raw (lastmodified);
CREATE INDEX release_raw_idx_lookupcount ON release_raw (lookupcount);

ALTER TABLE cdtoc_raw
    ADD CONSTRAINT cdtoc_raw_fk_release_raw
	FOREIGN KEY (release)
	REFERENCES release_raw(id);

ALTER TABLE track_raw
    ADD CONSTRAINT track_raw_fk_release_raw
	FOREIGN KEY (release)
	REFERENCES release_raw(id);

COMMIT;
