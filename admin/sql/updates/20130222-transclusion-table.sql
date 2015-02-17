\set ON_ERROR_STOP 1

BEGIN;

CREATE SCHEMA wikidocs;
SET search_path = 'wikidocs';

CREATE TABLE wikidocs_index (
    page_name TEXT NOT NULL PRIMARY KEY,
    revision INTEGER NOT NULL
);

COMMIT;
