\set ON_ERROR_STOP 1

BEGIN;

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

ALTER TABLE l_area_area_example ADD CONSTRAINT l_area_area_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_artist_example ADD CONSTRAINT l_area_artist_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_label_example ADD CONSTRAINT l_area_label_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_recording_example ADD CONSTRAINT l_area_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_release_example ADD CONSTRAINT l_area_release_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_release_group_example ADD CONSTRAINT l_area_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_url_example ADD CONSTRAINT l_area_url_example_pkey PRIMARY KEY (id);
ALTER TABLE l_area_work_example ADD CONSTRAINT l_area_work_example_pkey PRIMARY KEY (id);

COMMIT;
