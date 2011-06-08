BEGIN;

CREATE TABLE release_tag_raw
(
    release             INTEGER NOT NULL, -- PK
    editor              INTEGER NOT NULL, -- PK
    tag                 INTEGER NOT NULL -- PK
);

COMMIT;
