BEGIN;

CREATE TABLE url
(
    id                 SERIAL,
    gid                UUID NOT NULL,
    url                VARCHAR(255) NOT NULL,
    description        TEXT,
    refcount           INTEGER NOT NULL DEFAULT 0,
    editpending        INTEGER NOT NULL DEFAULT 0
);

ALTER TABLE url ADD CONSTRAINT url_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX url_idx_gid ON url (gid);
CREATE UNIQUE INDEX url_idx_url ON url (url);

COMMIT;
