-- Abstract: add table gid_redirect

\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE gid_redirect
(
    gid                 CHAR(36) NOT NULL,
    newid               INTEGER NOT NULL,
    tbl                 SMALLINT NOT NULL
);

ALTER TABLE gid_redirect ADD CONSTRAINT gid_redirect_pkey PRIMARY KEY (gid);
CREATE INDEX gid_redirect_newid ON gid_redirect (newid);

COMMIT;

-- vi: set ts=4 sw=4 et :
