CREATE TABLE url_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    newid               INTEGER NOT NULL -- references url.id
);

ALTER TABLE url_gid_redirect
   ADD CONSTRAINT url_gid_redirect_fk_newid
   FOREIGN KEY (newid)
   REFERENCES url(id);