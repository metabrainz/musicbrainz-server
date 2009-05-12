BEGIN;

CREATE TABLE medium
(
    id                 SERIAL,
    tracklist          INTEGER NOT NULL, -- references tracklist.id
    release            INTEGER NOT NULL, -- references release.id
    position           INTEGER NOT NULL,
    format             INTEGER, -- references medium_format.id
    name               VARCHAR(255),
    editpending        INTEGER NOT NULL DEFAULT 0
);

ALTER TABLE medium ADD CONSTRAINT medium_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX medium_idx_release ON medium (release, position);
CREATE INDEX medium_idx_tracklist ON medium (tracklist);

ALTER TABLE medium ADD CONSTRAINT medium_fk_tracklist
    FOREIGN KEY (tracklist) REFERENCES tracklist(id);

ALTER TABLE medium ADD CONSTRAINT medium_fk_release
    FOREIGN KEY (release) REFERENCES release(id);

ALTER TABLE medium ADD CONSTRAINT medium_fk_format
    FOREIGN KEY (format) REFERENCES medium_format(id);

COMMIT;
