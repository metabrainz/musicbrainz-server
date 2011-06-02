BEGIN;

CREATE TABLE release_tag
(
    release              INTEGER NOT NULL, -- PK, references release.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMIT;
