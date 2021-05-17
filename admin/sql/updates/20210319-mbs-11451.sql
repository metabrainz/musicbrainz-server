\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE place_meta ( -- replicate
    id                  INTEGER NOT NULL, -- PK, references place.id CASCADE
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER
);

CREATE TABLE place_rating_raw
(
    place               INTEGER NOT NULL, -- PK, references place.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

ALTER TABLE place_meta ADD CONSTRAINT place_meta_pkey PRIMARY KEY (id);
ALTER TABLE place_rating_raw ADD CONSTRAINT place_rating_raw_pkey PRIMARY KEY (place, editor);

CREATE OR REPLACE FUNCTION a_ins_place() RETURNS trigger AS $$
BEGIN
    -- add a new entry to the place_meta table
    INSERT INTO place_meta (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

INSERT INTO place_meta (id)
    (SELECT id FROM place);

CREATE INDEX place_rating_raw_idx_editor ON place_rating_raw (editor);

COMMIT;
