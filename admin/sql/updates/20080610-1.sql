\set ON_ERROR_STOP 1

BEGIN;

-- Introduces _meta tables containing entities metadata, starting with timestamps
CREATE TABLE artist_meta
(
    id          INTEGER NOT NULL,
    lastupdate  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE label_meta
(
    id          INTEGER NOT NULL,
    lastupdate  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE track_meta
(
    id          INTEGER NOT NULL
);

ALTER TABLE albummeta  ADD COLUMN lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Initial population
INSERT INTO artist_meta (id) SELECT id FROM artist;
INSERT INTO label_meta (id) SELECT id FROM label;
INSERT INTO track_meta (id) SELECT id FROM track;

-- primary keys
ALTER TABLE artist_meta ADD CONSTRAINT artist_meta_pkey PRIMARY KEY(id);
ALTER TABLE label_meta ADD CONSTRAINT label_meta_pkey PRIMARY KEY(id);
ALTER TABLE track_meta ADD CONSTRAINT track_meta_pkey PRIMARY KEY(id);

-- indexes
CREATE INDEX albummeta_lastupdate ON albummeta (lastupdate);
CREATE INDEX label_meta_lastupdate ON label_meta (lastupdate);
CREATE INDEX artist_meta_lastupdate ON artist_meta (lastupdate);

-- Create an index on the closed moderation expiretime so we can get some stats
CREATE INDEX moderation_closed_idx_closetime ON moderation_closed (closetime);
CREATE INDEX moderation_closed_idx_opentime ON moderation_closed (opentime);
CREATE INDEX release_releasedate ON release (releasedate);


COMMIT;
