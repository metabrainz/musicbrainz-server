\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE edit_genre
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    genre               INTEGER NOT NULL  -- PK, references genre.id CASCADE
);

ALTER TABLE edit_genre ADD CONSTRAINT edit_genre_pkey PRIMARY KEY (edit, genre);

CREATE INDEX edit_genre_idx ON edit_genre (genre);

COMMIT;
