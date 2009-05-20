BEGIN;

CREATE TABLE annotation
(
    id              SERIAL,
    editor          INTEGER NOT NULL, -- references editor.id
    text            TEXT,
    changelog       VARCHAR(255),
    created         TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE artist_annotation
(
    artist          INTEGER NOT NULL, -- references artist.id
    annotation      INTEGER NOT NULL -- references annotation.id
);

CREATE TABLE label_annotation
(
    label           INTEGER NOT NULL, -- references label
    annotation      INTEGER NOT NULL -- references annotation.id
);

CREATE TABLE recording_annotation
(
    recording       INTEGER NOT NULL, -- references recording
    annotation      INTEGER NOT NULL -- references annotation.id
);

CREATE TABLE release_annotation
(
    release         INTEGER NOT NULL, -- references release
    annotation      INTEGER NOT NULL -- references annotation.id
);

CREATE TABLE release_group_annotation
(
    release_group   INTEGER NOT NULL, -- references release_group
    annotation      INTEGER NOT NULL -- references annotation.id
);

CREATE TABLE work_annotation
(
    work            INTEGER NOT NULL, -- references work
    annotation      INTEGER NOT NULL -- references annotation.id
);

ALTER TABLE annotation ADD CONSTRAINT annotation_pkey PRIMARY KEY (id);
ALTER TABLE artist_annotation ADD CONSTRAINT artist_annotation_pkey PRIMARY KEY (artist, annotation);
ALTER TABLE label_annotation ADD CONSTRAINT label_annotation_pkey PRIMARY KEY (label, annotation);
ALTER TABLE recording_annotation ADD CONSTRAINT recording_annotation_pkey PRIMARY KEY (recording, annotation);
ALTER TABLE release_annotation ADD CONSTRAINT release_annotation_pkey PRIMARY KEY (release, annotation);
ALTER TABLE release_group_annotation ADD CONSTRAINT release_group_annotation_pkey PRIMARY KEY (release_group, annotation);
ALTER TABLE work_annotation ADD CONSTRAINT work_annotation_pkey PRIMARY KEY (work, annotation);

ALTER TABLE annotation ADD CONSTRAINT annotation_fk_editor FOREIGN KEY (editor) REFERENCES editor(id);
ALTER TABLE artist_annotation ADD CONSTRAINT artist_annotation_fk_artist FOREIGN KEY (artist) REFERENCES artist(id);
ALTER TABLE artist_annotation ADD CONSTRAINT artist_annotation_fk_annotation FOREIGN KEY (annotation) REFERENCES annotation(id);
ALTER TABLE label_annotation ADD CONSTRAINT label_annotation_fk_label FOREIGN KEY (label) REFERENCES label(id);
ALTER TABLE label_annotation ADD CONSTRAINT label_annotation_fk_annotation FOREIGN KEY (annotation) REFERENCES annotation(id);
ALTER TABLE recording_annotation ADD CONSTRAINT recording_annotation_fk_recording FOREIGN KEY (recording) REFERENCES recording(id);
ALTER TABLE recording_annotation ADD CONSTRAINT recording_annotation_fk_annotation FOREIGN KEY (annotation) REFERENCES annotation(id);
ALTER TABLE release_annotation ADD CONSTRAINT release_annotation_fk_release FOREIGN KEY (release) REFERENCES release(id);
ALTER TABLE release_annotation ADD CONSTRAINT release_annotation_fk_annotation FOREIGN KEY (annotation) REFERENCES annotation(id);
ALTER TABLE release_group_annotation ADD CONSTRAINT release_group_annotation_fk_release_group FOREIGN KEY (release_group) REFERENCES release_group(id);
ALTER TABLE release_group_annotation ADD CONSTRAINT release_group_annotation_fk_annotation FOREIGN KEY (annotation) REFERENCES annotation(id);
ALTER TABLE work_annotation ADD CONSTRAINT work_annotation_fk_work FOREIGN KEY (work) REFERENCES work(id);
ALTER TABLE work_annotation ADD CONSTRAINT work_annotation_fk_annotation FOREIGN KEY (annotation) REFERENCES annotation(id);

COMMIT;