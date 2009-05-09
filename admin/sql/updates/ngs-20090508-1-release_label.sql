BEGIN;

CREATE TABLE release_label (
    id                  SERIAL,
    release             INTEGER NOT NULL, -- references release.id
    position            INTEGER NOT NULL,
    label               INTEGER, -- references label.id
    catno               VARCHAR(255)
);

ALTER TABLE release_label ADD CONSTRAINT release_label_pk PRIMARY KEY (id);

CREATE INDEX release_label_idx_release ON release_label (release);
CREATE INDEX release_label_idx_label ON release_label (label);

ALTER TABLE release_label ADD CONSTRAINT release_label_fk_release
    FOREIGN KEY (release) REFERENCES release(id) ON DELETE CASCADE;

ALTER TABLE release_label ADD CONSTRAINT release_label_fk_label
    FOREIGN KEY (label) REFERENCES label(id);

COMMIT;
