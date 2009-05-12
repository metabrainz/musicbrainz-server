BEGIN;

CREATE TABLE medium_format
(
    id                 SERIAL,
    name               VARCHAR(100) NOT NULL
);

ALTER TABLE medium_format ADD CONSTRAINT medium_format_pk PRIMARY KEY (id);

COMMIT;
