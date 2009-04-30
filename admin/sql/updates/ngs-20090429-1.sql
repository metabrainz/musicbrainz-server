BEGIN;


CREATE TABLE gender (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

ALTER TABLE gender ADD CONSTRAINT gender_pk PRIMARY KEY (id);


COMMIT;
