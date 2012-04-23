BEGIN;

CREATE TABLE release_group_secondary_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE release_group_secondary_type_join (
    release_group INTEGER NOT NULL REFERENCES release_group (id),
    secondary_type INTEGER NOT NULL REFERENCES release_group_secondary_type (id),
    PRIMARY KEY (release_group, secondary_type)
);

ALTER TABLE release_group_type RENAME to release_group_primary_type;

COMMIT;
