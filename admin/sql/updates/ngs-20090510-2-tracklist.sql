BEGIN;

CREATE TABLE tracklist
(
    id                 SERIAL,
    trackcount         INTEGER NOT NULL DEFAULT 0
);

ALTER TABLE tracklist ADD CONSTRAINT tracklist_pk PRIMARY KEY (id);

CREATE INDEX tracklist_idx_trackcount ON tracklist (trackcount);

COMMIT;
