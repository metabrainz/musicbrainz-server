BEGIN;

CREATE TABLE artist_gid_redirect
(
    gid             UUID NOT NULL,
    newid           INTEGER NOT NULL -- references artist.id
);

CREATE TABLE label_gid_redirect
(
    gid             UUID NOT NULL,
    newid           INTEGER NOT NULL -- references label.id
);

CREATE TABLE recording_gid_redirect
(
    gid             UUID NOT NULL,
    newid           INTEGER NOT NULL -- references recording.id
);

CREATE TABLE release_gid_redirect
(
    gid             UUID NOT NULL,
    newid           INTEGER NOT NULL -- references release.id
);

CREATE TABLE release_group_gid_redirect
(
    gid             UUID NOT NULL,
    newid           INTEGER NOT NULL -- references release_group.id
);

CREATE TABLE work_gid_redirect
(
    gid             UUID NOT NULL,
    newid           INTEGER NOT NULL -- references work.id
);

ALTER TABLE artist_gid_redirect ADD CONSTRAINT artist_gid_redirect_pkey PRIMARY KEY (gid);
ALTER TABLE label_gid_redirect ADD CONSTRAINT label_gid_redirect_pkey PRIMARY KEY (gid);
ALTER TABLE recording_gid_redirect ADD CONSTRAINT recording_gid_redirect_pkey PRIMARY KEY (gid);
ALTER TABLE release_gid_redirect ADD CONSTRAINT release_gid_redirect_pkey PRIMARY KEY (gid);
ALTER TABLE release_group_gid_redirect ADD CONSTRAINT release_group_gid_redirect_pkey PRIMARY KEY (gid);
ALTER TABLE work_gid_redirect ADD CONSTRAINT work_gid_redirect_pkey PRIMARY KEY (gid);

ALTER TABLE artist_gid_redirect ADD CONSTRAINT artist_gid_redirectt_fk_newid FOREIGN KEY (newid) REFERENCES artist(id);
ALTER TABLE label_gid_redirect ADD CONSTRAINT label_gid_redirectt_fk_newid FOREIGN KEY (newid) REFERENCES label(id);
ALTER TABLE recording_gid_redirect ADD CONSTRAINT recording_gid_redirectt_fk_newid FOREIGN KEY (newid) REFERENCES recording(id);
ALTER TABLE release_gid_redirect ADD CONSTRAINT release_gid_redirectt_fk_newid FOREIGN KEY (newid) REFERENCES release(id);
ALTER TABLE release_group_gid_redirect ADD CONSTRAINT release_group_gid_redirectt_fk_newid FOREIGN KEY (newid) REFERENCES release_group(id);
ALTER TABLE work_gid_redirect ADD CONSTRAINT work_gid_redirectt_fk_newid FOREIGN KEY (newid) REFERENCES work(id);

COMMIT;