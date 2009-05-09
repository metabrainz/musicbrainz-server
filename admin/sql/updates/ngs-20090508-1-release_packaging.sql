BEGIN;

CREATE TABLE release_packaging
(
    id                 SERIAL,
    name               VARCHAR(255) NOT NULL
);

ALTER TABLE release_packaging ADD CONSTRAINT release_packaging_pk PRIMARY KEY (id);

COMMIT;
