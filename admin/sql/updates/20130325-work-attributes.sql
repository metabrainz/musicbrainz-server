\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE work_attribute_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL
);

CREATE TABLE work_attribute_type_value (
    id                  SERIAL,
    work_attribute_type INTEGER NOT NULL,
    value               TEXT
);

CREATE TABLE work_attribute (
    id                          SERIAL,
    work                        INTEGER NOT NULL,
    work_attribute_type         INTEGER NOT NULL,
    work_attribute_type_value   INTEGER NOT NULL,
    work_attribute_text         TEXT
);

ALTER TABLE work_attribute ADD CONSTRAINT work_attribute_pkey PRIMARY KEY (id);
ALTER TABLE work_attribute_type ADD CONSTRAINT work_attribute_type_pkey PRIMARY KEY (id);
ALTER TABLE work_attribute_type_value ADD CONSTRAINT work_attribute_type_value_pkey PRIMARY KEY (id);

CREATE INDEX work_attribute_type_value_idx_name ON work_attribute_type_value (work_attribute_type);

COMMIT;
