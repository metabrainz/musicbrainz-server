-- Abstract: create annotation table

\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE annotation
(
    id                  SERIAL,
    moderator           INTEGER NOT NULL, -- references moderator
    type                SMALLINT NOT NULL,
    rowid               INTEGER NOT NULL, -- conditional reference
    text                TEXT,
    changelog           VARCHAR(255),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    moderation          INTEGER NOT NULL DEFAULT 0,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX annotation_rowidindex ON annotation (rowid);
CREATE UNIQUE INDEX annotation_moderationindex ON annotation (moderation);

COMMIT;

-- vi: set ts=4 sw=4 et :
