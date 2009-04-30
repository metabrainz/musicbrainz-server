BEGIN;

CREATE TABLE country (
    id                  SERIAL,
    isocode             VARCHAR(2) NOT NULL,
    name                VARCHAR(255) NOT NULL
);

ALTER TABLE country ADD CONSTRAINT country_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX country_idx_isocode ON country (isocode);

COMMIT;
