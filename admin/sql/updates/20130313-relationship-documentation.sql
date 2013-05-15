\set ON_ERROR_STOP 1

BEGIN;

CREATE SCHEMA documentation;
SET search_path = 'documentation';

CREATE TABLE l_area_area_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_area.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_artist_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_artist.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_label_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_label.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_recording_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_release_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_release_group_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_url_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_area_work_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_artist_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_artist.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_label_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_label.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_recording_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_release_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_release_group_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_url_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_artist_work_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);



CREATE TABLE l_label_label_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_label.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_recording_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_release_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_release_group_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_url_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_label_work_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);



CREATE TABLE l_recording_recording_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_recording_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_recording_release_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_recording_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_recording_release_group_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_recording_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_recording_url_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_recording_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_recording_work_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_recording_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);



CREATE TABLE l_release_release_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_release_release_group_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_release_url_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_release_work_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);



CREATE TABLE l_release_group_release_group_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_group_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_release_group_url_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_group_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_release_group_work_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_release_group_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);



CREATE TABLE l_url_url_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_url_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE l_url_work_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_url_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);



CREATE TABLE l_work_work_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_work_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


CREATE TABLE link_type_documentation (
  id INTEGER NOT NULL, -- PK, references musicbrainz.link_type
  documentation TEXT NOT NULL,
  examples_deleted SMALLINT NOT NULL DEFAULT 0
);

INSERT INTO link_type_documentation (id, documentation)
SELECT id, '' FROM musicbrainz.link_type;

ALTER TABLE l_area_area_example ADD CONSTRAINT l_area_area_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_artist_example ADD CONSTRAINT l_area_artist_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_label_example ADD CONSTRAINT l_area_label_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_recording_example ADD CONSTRAINT l_area_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_release_example ADD CONSTRAINT l_area_release_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_release_group_example ADD CONSTRAINT l_area_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_url_example ADD CONSTRAINT l_area_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_work_example ADD CONSTRAINT l_area_work_example_pkey PRIMARY KEY (id);

ALTER TABLE l_artist_artist_example ADD CONSTRAINT l_artist_artist_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_label_example ADD CONSTRAINT l_artist_label_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_recording_example ADD CONSTRAINT l_artist_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_release_example ADD CONSTRAINT l_artist_release_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_release_group_example ADD CONSTRAINT l_artist_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_url_example ADD CONSTRAINT l_artist_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_work_example ADD CONSTRAINT l_artist_work_example_pkey PRIMARY KEY (id);

ALTER TABLE l_label_label_example ADD CONSTRAINT l_label_label_example_pkey PRIMARY KEY (id);
ALTER TABLE l_label_recording_example ADD CONSTRAINT l_label_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE l_label_release_example ADD CONSTRAINT l_label_release_example_pkey PRIMARY KEY (id);
ALTER TABLE l_label_release_group_example ADD CONSTRAINT l_label_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_label_url_example ADD CONSTRAINT l_label_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_label_work_example ADD CONSTRAINT l_label_work_example_pkey PRIMARY KEY (id);

ALTER TABLE l_recording_recording_example ADD CONSTRAINT l_recording_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_release_example ADD CONSTRAINT l_recording_release_example_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_release_group_example ADD CONSTRAINT l_recording_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_url_example ADD CONSTRAINT l_recording_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_work_example ADD CONSTRAINT l_recording_work_example_pkey PRIMARY KEY (id);

ALTER TABLE l_release_group_release_group_example ADD CONSTRAINT l_release_group_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_release_group_url_example ADD CONSTRAINT l_release_group_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_release_group_work_example ADD CONSTRAINT l_release_group_work_example_pkey PRIMARY KEY (id);

ALTER TABLE l_release_release_example ADD CONSTRAINT l_release_release_example_pkey PRIMARY KEY (id);
ALTER TABLE l_release_release_group_example ADD CONSTRAINT l_release_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_release_url_example ADD CONSTRAINT l_release_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_release_work_example ADD CONSTRAINT l_release_work_example_pkey PRIMARY KEY (id);

ALTER TABLE l_url_url_example ADD CONSTRAINT l_url_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_url_work_example ADD CONSTRAINT l_url_work_example_pkey PRIMARY KEY (id);
ALTER TABLE l_work_work_example ADD CONSTRAINT l_work_work_example_pkey PRIMARY KEY (id);

ALTER TABLE link_type_documentation ADD CONSTRAINT link_type_documentation_pkey PRIMARY KEY (id);

COMMIT;
