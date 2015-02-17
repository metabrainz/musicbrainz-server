\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE documentation.l_area_instrument_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_instrument.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_artist_instrument_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_instrument.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_instrument_instrument_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_instrument.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_instrument_label_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_label.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_instrument_place_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_place.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_instrument_recording_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_instrument_release_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_instrument_release_group_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_instrument_url_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_instrument_work_example (
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

ALTER TABLE documentation.l_area_instrument_example ADD CONSTRAINT l_area_instrument_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_artist_instrument_example ADD CONSTRAINT l_artist_instrument_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_instrument_instrument_example ADD CONSTRAINT l_instrument_instrument_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_instrument_label_example ADD CONSTRAINT l_instrument_label_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_instrument_place_example ADD CONSTRAINT l_instrument_place_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_instrument_recording_example ADD CONSTRAINT l_instrument_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_instrument_release_example ADD CONSTRAINT l_instrument_release_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_instrument_release_group_example ADD CONSTRAINT l_instrument_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_instrument_url_example ADD CONSTRAINT l_instrument_url_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_instrument_work_example ADD CONSTRAINT l_instrument_work_example_pkey PRIMARY KEY (id);

COMMIT;
