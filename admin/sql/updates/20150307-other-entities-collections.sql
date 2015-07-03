\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor_collection_type
      DROP CONSTRAINT IF EXISTS allowed_collection_entity_type;

-- Commented-out because code was not ready for this yet.
--INSERT INTO editor_collection_type (id, name, entity_type, parent, child_order) VALUES
--        (7, 'Area', 'area', NULL, 2),
--        (8, 'Artist', 'artist', NULL, 2),
--        (9, 'Instrument', 'instrument', NULL, 2),
--        (10, 'Label', 'label', NULL, 2),
--        (11, 'Place', 'place', NULL, 2),
--        (12, 'Recording', 'recording', NULL, 2),
--        (13, 'Release group', 'release_group', NULL, 2),
--        (14, 'Series', 'series', NULL, 2),
--        (15, 'Work', 'work', NULL, 2);

CREATE TABLE editor_collection_area (
    collection INTEGER NOT NULL,
    area INTEGER NOT NULL
);

ALTER TABLE editor_collection_area ADD CONSTRAINT editor_collection_area_pkey PRIMARY KEY (collection, area);


CREATE TABLE editor_collection_artist (
    collection INTEGER NOT NULL,
    artist INTEGER NOT NULL
);

ALTER TABLE editor_collection_artist ADD CONSTRAINT editor_collection_artist_pkey PRIMARY KEY (collection, artist);


CREATE TABLE editor_collection_instrument (
    collection INTEGER NOT NULL,
    instrument INTEGER NOT NULL
);

ALTER TABLE editor_collection_instrument ADD CONSTRAINT editor_collection_instrument_pkey PRIMARY KEY (collection, instrument);


CREATE TABLE editor_collection_label (
    collection INTEGER NOT NULL,
    label INTEGER NOT NULL
);

ALTER TABLE editor_collection_label ADD CONSTRAINT editor_collection_label_pkey PRIMARY KEY (collection, label);


CREATE TABLE editor_collection_place (
    collection INTEGER NOT NULL,
    place INTEGER NOT NULL
);

ALTER TABLE editor_collection_place ADD CONSTRAINT editor_collection_place_pkey PRIMARY KEY (collection, place);


CREATE TABLE editor_collection_recording (
    collection INTEGER NOT NULL,
    recording INTEGER NOT NULL
);

ALTER TABLE editor_collection_recording ADD CONSTRAINT editor_collection_recording_pkey PRIMARY KEY (collection, recording);


CREATE TABLE editor_collection_release_group (
    collection INTEGER NOT NULL,
    release_group INTEGER NOT NULL
);

ALTER TABLE editor_collection_release_group ADD CONSTRAINT editor_collection_release_group_pkey PRIMARY KEY (collection, release_group);


CREATE TABLE editor_collection_series (
    collection INTEGER NOT NULL,
    series INTEGER NOT NULL
);

ALTER TABLE editor_collection_series ADD CONSTRAINT editor_collection_series_pkey PRIMARY KEY (collection, series);


CREATE TABLE editor_collection_work (
    collection INTEGER NOT NULL,
    work INTEGER NOT NULL
);

ALTER TABLE editor_collection_work ADD CONSTRAINT editor_collection_work_pkey PRIMARY KEY (collection, work);

COMMIT;
