BEGIN;


CREATE TABLE artist_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

ALTER TABLE artist_type ADD CONSTRAINT artist_type_pk PRIMARY KEY (id);


COMMIT;
