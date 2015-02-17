\set ON_ERROR_STOP 1

BEGIN;

-----------------------
-- CREATE NEW TABLES --
-----------------------

CREATE TABLE work_attribute_type (
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL
);

CREATE TABLE work_attribute_type_allowed_value (
    id                  SERIAL,  -- PK
    work_attribute_type INTEGER NOT NULL, -- references work_attribute_type.id
    value               TEXT
);

CREATE TABLE work_attribute (
    id                                  SERIAL,  -- PK
    work                                INTEGER NOT NULL, -- references work.id
    work_attribute_type                 INTEGER NOT NULL, -- references work_attribute_type.id
    work_attribute_type_allowed_value   INTEGER, -- references work_attribute_type_allowed_value.id
    work_attribute_text                 TEXT
    -- Either it has a value from the allowed list, or is free text
    CHECK ( work_attribute_type_allowed_value IS NULL OR work_attribute_text IS NULL )
);

----------------------
-- ADD PRIMARY KEYS --
----------------------

ALTER TABLE work_attribute ADD CONSTRAINT work_attribute_pkey PRIMARY KEY (id);
ALTER TABLE work_attribute_type ADD CONSTRAINT work_attribute_type_pkey PRIMARY KEY (id);
ALTER TABLE work_attribute_type_allowed_value ADD CONSTRAINT work_attribute_type_allowed_value_pkey PRIMARY KEY (id);

--------------------
-- CREATE INDEXES --
--------------------

CREATE INDEX work_attribute_type_allowed_value_idx_name ON work_attribute_type_allowed_value (work_attribute_type);
CREATE INDEX work_attribute_idx_work ON work_attribute (work);

COMMIT;
