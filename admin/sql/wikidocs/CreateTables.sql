BEGIN;

SET search_path = 'wikidocs';

CREATE TABLE wikidocs_index (
    page_name TEXT NOT NULL, -- PK
    revision INTEGER NOT NULL
);

COMMIT;
