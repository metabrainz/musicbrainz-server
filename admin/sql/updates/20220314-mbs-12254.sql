\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE genre_annotation ( -- replicate (verbose)
    genre       INTEGER NOT NULL, -- PK, references genre.id
    annotation  INTEGER NOT NULL -- PK, references annotation.id
);

ALTER TABLE genre_annotation ADD CONSTRAINT genre_annotation_pkey PRIMARY KEY (genre, annotation);

COMMIT;
