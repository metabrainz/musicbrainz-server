BEGIN;

CREATE TABLE release_status
(
    id                 SERIAL,
    name               VARCHAR(255) NOT NULL
);

ALTER TABLE release_status ADD CONSTRAINT release_status_pk PRIMARY KEY (id);

COMMIT;
