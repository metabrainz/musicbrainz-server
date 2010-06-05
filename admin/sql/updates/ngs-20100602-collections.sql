BEGIN;

ALTER TABLE editor_collection RENAME TO collection;
ALTER TABLE editor_collection_release RENAME TO collection_release;

ALTER TABLE collection ADD COLUMN gid UUID, ADD COLUMN name VARCHAR, ADD COLUMN public BOOLEAN NOT NULL DEFAULT false;

UPDATE collection SET name='My Collection';
UPDATE collection SET gid=generate_uuid_v4() WHERE gid IS NULL;

ALTER TABLE collection ALTER COLUMN name SET NOT NULL, ALTER COLUMN gid SET NOT NULL;

CREATE UNIQUE INDEX collection_idx_gid ON collection (gid);
CREATE INDEX collection_idx_name ON collection (name);

CREATE TABLE collection_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    newid               INTEGER NOT NULL -- references collection.id
);

ALTER TABLE collection_gid_redirect
   ADD CONSTRAINT collection_gid_redirect_fk_newid
   FOREIGN KEY (newid)
   REFERENCES collection(id);

ALTER TABLE collection_gid_redirect ADD CONSTRAINT collection_gid_redirect_pkey PRIMARY KEY (gid);

COMMIT;
