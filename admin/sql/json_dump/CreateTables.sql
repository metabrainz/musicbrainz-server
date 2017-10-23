\set ON_ERROR_STOP 1

BEGIN;

SET search_path = json_dump, public;

CREATE TABLE control (
    last_processed_replication_sequence     INTEGER,
    full_json_dump_replication_sequence     INTEGER
);

CREATE TABLE tmp_checked_entities (
    id          INTEGER NOT NULL,
    entity_type VARCHAR(50) NOT NULL
);

CREATE TABLE deleted_entities (
    entity_type             VARCHAR(50) NOT NULL, -- PK
    id                      INTEGER NOT NULL, -- PK
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE area_json (
    id                      INTEGER NOT NULL, -- PK
    replication_sequence    INTEGER NOT NULL, -- PK
    json                    JSONB NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE artist_json (
    id                      INTEGER NOT NULL, -- PK
    replication_sequence    INTEGER NOT NULL, -- PK
    json                    JSONB NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE event_json (
    id                      INTEGER NOT NULL, -- PK
    replication_sequence    INTEGER NOT NULL, -- PK
    json                    JSONB NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE instrument_json (
    id                      INTEGER NOT NULL, -- PK
    replication_sequence    INTEGER NOT NULL, -- PK
    json                    JSONB NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE label_json (
    id                      INTEGER NOT NULL, -- PK
    replication_sequence    INTEGER NOT NULL, -- PK
    json                    JSONB NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE place_json (
    id                      INTEGER NOT NULL, -- PK
    replication_sequence    INTEGER NOT NULL, -- PK
    json                    JSONB NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE recording_json (
    id                      INTEGER NOT NULL, -- PK
    replication_sequence    INTEGER NOT NULL, -- PK
    json                    JSONB NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE release_json (
    id                      INTEGER NOT NULL, -- PK
    replication_sequence    INTEGER NOT NULL, -- PK
    json                    JSONB NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE release_group_json (
    id                      INTEGER NOT NULL, -- PK
    replication_sequence    INTEGER NOT NULL, -- PK
    json                    JSONB NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE series_json (
    id                      INTEGER NOT NULL, -- PK
    replication_sequence    INTEGER NOT NULL, -- PK
    json                    JSONB NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE work_json (
    id                      INTEGER NOT NULL, -- PK
    replication_sequence    INTEGER NOT NULL, -- PK
    json                    JSONB NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE
);

COMMIT;
