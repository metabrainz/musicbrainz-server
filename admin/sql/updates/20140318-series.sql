\set ON_ERROR_STOP 1
BEGIN;

-----------------------
-- CREATE NEW TABLES --
-----------------------

CREATE TABLE series
(
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                VARCHAR NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    type                INTEGER NOT NULL, -- references series_type.id
    ordering_attribute  INTEGER NOT NULL, -- references link_text_attribute_type.attribute_type
    ordering_type       INTEGER NOT NULL, -- references series_ordering_type.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE series_type
(
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    entity_type         VARCHAR(50) NOT NULL,
    parent              INTEGER, -- references series_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT
);

CREATE TABLE series_ordering_type
(
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references series_ordering_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT
);

CREATE TABLE series_deletion
(
    gid                 UUID NOT NULL, -- PK
    last_known_name     VARCHAR NOT NULL,
    last_known_comment  TEXT NOT NULL,
    deleted_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE series_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL,
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE series_alias_type
(
    id                  SERIAL,
    name                TEXT NOT NULL
);

CREATE TABLE series_alias
(
    id                  SERIAL,
    series              INTEGER NOT NULL, -- references series.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references series_alias_type.id
    sort_name           VARCHAR NOT NULL,
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    primary_for_locale  BOOLEAN NOT NULL DEFAULT FALSE,
    ended               BOOLEAN NOT NULL DEFAULT FALSE
      CHECK (
        (
          -- If any end date fields are not null, then ended must be true
          (end_date_year IS NOT NULL OR
           end_date_month IS NOT NULL OR
           end_date_day IS NOT NULL) AND
          ended = TRUE
        ) OR (
          -- Otherwise, all end date fields must be null
          (end_date_year IS NULL AND
           end_date_month IS NULL AND
           end_date_day IS NULL)
        )
      ),
    CONSTRAINT primary_check CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL)),
    CONSTRAINT search_hints_are_empty
      CHECK (
        (type <> 2) OR (
          type = 2 AND sort_name = name AND
          begin_date_year IS NULL AND begin_date_month IS NULL AND begin_date_day IS NULL AND
          end_date_year IS NULL AND end_date_month IS NULL AND end_date_day IS NULL AND
          primary_for_locale IS FALSE AND locale IS NULL
        )
      )
);

CREATE TABLE series_annotation (
    series              INTEGER NOT NULL, -- PK, references series.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE editor_subscribe_series
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    series              INTEGER NOT NULL, -- references series.id
    last_edit_sent      INTEGER NOT NULL -- references edit.id
);

CREATE TABLE editor_subscribe_series_deleted
(
    editor              INTEGER NOT NULL, -- PK, references editor.id
    gid                 UUID NOT NULL, -- PK, references series_deletion.gid
    deleted_by          INTEGER NOT NULL -- references edit.id
);

CREATE TABLE l_area_series
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_artist_series
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_label_series
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_place_series
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_recording_series
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_release_series
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_release_group_series
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_series_series
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_series_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_series_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references series.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE link_text_attribute_type (
    attribute_type      INT NOT NULL -- PK, references link_attribute_type.id CASCADE
);

CREATE TABLE link_attribute_text_value (
    link                INT NOT NULL, -- PK, references link.id
    attribute_type      INT NOT NULL, -- PK, references link_text_attribute_type.attribute_type
    text_value          TEXT NOT NULL
);

CREATE TABLE orderable_link_type (
    link_type           INTEGER NOT NULL, -- PK
    direction           SMALLINT NOT NULL DEFAULT 1 CHECK (direction = 1 OR direction = 2)
);

-----------------------
-- CREATE NEW VIEWS  --
-----------------------

CREATE OR REPLACE VIEW recording_series AS
    SELECT entity0 AS recording, entity1 AS series, link_order, text_value
    FROM l_recording_series lrs
    JOIN series s ON s.id = lrs.entity1
    JOIN link l ON l.id = lrs.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = 'ea6f0698-6782-30d6-b16d-293081b66774')
    JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

CREATE OR REPLACE VIEW release_series AS
    SELECT entity0 AS release, entity1 AS series, link_order, text_value
    FROM l_release_series lrs
    JOIN series s ON s.id = lrs.entity1
    JOIN link l ON l.id = lrs.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = '3fa29f01-8e13-3e49-9b0a-ad212aa2f81d')
    JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

CREATE OR REPLACE VIEW release_group_series AS
    SELECT entity0 AS release_group, entity1 AS series, link_order, text_value
    FROM l_release_group_series lrgs
    JOIN series s ON s.id = lrgs.entity1
    JOIN link l ON l.id = lrgs.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = '01018437-91d8-36b9-bf89-3f885d53b5bd')
    JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

CREATE OR REPLACE VIEW work_series AS
    SELECT entity1 AS work, entity0 AS series, link_order, text_value
    FROM l_series_work lsw
    JOIN series s ON s.id = lsw.entity0
    JOIN link l ON l.id = lsw.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0')
    JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

-------------------------
-- INSERT INITIAL DATA --
-------------------------

-- new relationship types
INSERT INTO link_type (gid, entity_type0, entity_type1, name, description, link_phrase, reverse_link_phrase, long_link_phrase) VALUES
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/recording/series/part_of'), 'recording', 'series', 'part of', 'Indicates that the recording is part of a series.', 'parts', 'part of', 'has part'),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/release/series/part_of'), 'release', 'series', 'part of', 'Indicates that the release is part of a series.', 'part of', 'parts', 'has part'),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/release_group/series/part_of'), 'release_group', 'series', 'part of', 'Indicates that the release group is part of a series.', 'part of', 'parts', 'has part'),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/series/work/part_of'), 'series', 'work', 'part of', 'Indicates that the work is part of a series.', 'parts', 'part of', 'has part')
    RETURNING id, gid, entity_type0, entity_type1, name, long_link_phrase;

INSERT INTO orderable_link_type (link_type, direction) VALUES
    ((SELECT id FROM link_type WHERE gid = 'ea6f0698-6782-30d6-b16d-293081b66774'), 2),
    ((SELECT id FROM link_type WHERE gid = '3fa29f01-8e13-3e49-9b0a-ad212aa2f81d'), 2),
    ((SELECT id FROM link_type WHERE gid = '01018437-91d8-36b9-bf89-3f885d53b5bd'), 2),
    ((SELECT id FROM link_type WHERE gid = 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0'), 1);

INSERT INTO series_type (name, entity_type, parent, child_order, description) VALUES
    ('Recording', 'recording', NULL, 0, 'Indicates that the series is of recordings.'),
    ('Release', 'release', NULL, 1, 'Indicates that the series is of releases.'),
    ('Release group', 'release_group', NULL, 2, 'Indicates that the series is of release groups.'),
    ('Work', 'work', NULL, 3, 'Indicates that the series is of works.'),
    ('Catalog', 'work', 4, 0, 'Indicates that the series is a works catalog.');

INSERT INTO series_ordering_type (name, parent, child_order, description) VALUES
    ('Automatic', NULL, 0, 'Sorts the items in the series automatically by their ordering attribute, using a natural sort order.'),
    ('Manual', NULL, 1, 'Allows for manually setting the position of each item in the series.');

INSERT INTO series_alias_type (name) VALUES ('Series name'), ('Search hint');

--------------------
-- CREATE INDEXES --
--------------------

ALTER TABLE editor_subscribe_series ADD CONSTRAINT editor_subscribe_series_pkey PRIMARY KEY (id);
ALTER TABLE editor_subscribe_series_deleted ADD CONSTRAINT editor_subscribe_series_deleted_pkey PRIMARY KEY (editor, gid);
ALTER TABLE l_area_series ADD CONSTRAINT l_area_series_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_series ADD CONSTRAINT l_artist_series_pkey PRIMARY KEY (id);
ALTER TABLE l_label_series ADD CONSTRAINT l_label_series_pkey PRIMARY KEY (id);
ALTER TABLE l_place_series ADD CONSTRAINT l_place_series_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_series ADD CONSTRAINT l_recording_series_pkey PRIMARY KEY (id);
ALTER TABLE l_release_group_series ADD CONSTRAINT l_release_group_series_pkey PRIMARY KEY (id);
ALTER TABLE l_release_series ADD CONSTRAINT l_release_series_pkey PRIMARY KEY (id);
ALTER TABLE l_series_url ADD CONSTRAINT l_series_url_pkey PRIMARY KEY (id);
ALTER TABLE l_series_work ADD CONSTRAINT l_series_work_pkey PRIMARY KEY (id);
ALTER TABLE link_attribute_text_value ADD CONSTRAINT link_attribute_text_value_pkey PRIMARY KEY (link, attribute_type);
ALTER TABLE link_text_attribute_type ADD CONSTRAINT link_text_attribute_type_pkey PRIMARY KEY (attribute_type);
ALTER TABLE series ADD CONSTRAINT series_pkey PRIMARY KEY (id);
ALTER TABLE series_alias ADD CONSTRAINT series_alias_pkey PRIMARY KEY (id);
ALTER TABLE series_alias_type ADD CONSTRAINT series_alias_type_pkey PRIMARY KEY (id);
ALTER TABLE series_annotation ADD CONSTRAINT series_annotation_pkey PRIMARY KEY (series, annotation);
ALTER TABLE series_deletion ADD CONSTRAINT series_deletion_pkey PRIMARY KEY (gid);
ALTER TABLE series_gid_redirect ADD CONSTRAINT series_gid_redirect_pkey PRIMARY KEY (gid);
ALTER TABLE series_ordering_type ADD CONSTRAINT series_ordering_type_pkey PRIMARY KEY (id);
ALTER TABLE series_type ADD CONSTRAINT series_type_pkey PRIMARY KEY (id);

CREATE UNIQUE INDEX l_area_series_idx_uniq ON l_area_series (entity0, entity1, link);
CREATE UNIQUE INDEX l_artist_series_idx_uniq ON l_artist_series (entity0, entity1, link);
CREATE UNIQUE INDEX l_label_series_idx_uniq ON l_label_series (entity0, entity1, link);
CREATE UNIQUE INDEX l_place_series_idx_uniq ON l_place_series (entity0, entity1, link);
CREATE UNIQUE INDEX l_recording_series_idx_uniq ON l_recording_series (entity0, entity1, link);
CREATE UNIQUE INDEX l_release_series_idx_uniq ON l_release_series (entity0, entity1, link);
CREATE UNIQUE INDEX l_release_group_series_idx_uniq ON l_release_group_series (entity0, entity1, link);
CREATE UNIQUE INDEX l_series_url_idx_uniq ON l_series_url (entity0, entity1, link);
CREATE UNIQUE INDEX l_series_work_idx_uniq ON l_series_work (entity0, entity1, link);

CREATE INDEX l_area_series_idx_entity1 ON l_area_series (entity1);
CREATE INDEX l_artist_series_idx_entity1 ON l_artist_series (entity1);
CREATE INDEX l_label_series_idx_entity1 ON l_label_series (entity1);
CREATE INDEX l_place_series_idx_entity1 ON l_place_series (entity1);
CREATE INDEX l_recording_series_idx_entity1 ON l_recording_series (entity1);
CREATE INDEX l_release_series_idx_entity1 ON l_release_series (entity1);
CREATE INDEX l_release_group_series_idx_entity1 ON l_release_group_series (entity1);
CREATE INDEX l_series_url_idx_entity1 ON l_series_url (entity1);
CREATE INDEX l_series_work_idx_entity1 ON l_series_work (entity1);

CREATE UNIQUE INDEX series_idx_gid ON series (gid);
CREATE INDEX series_idx_name ON series (name);

CREATE INDEX series_alias_idx_series ON series_alias (series);
CREATE UNIQUE INDEX series_alias_idx_primary ON series_alias (series, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX series_idx_txt ON series USING gin(to_tsvector('mb_simple', name));

-----------------------------
-- MIGRATE EXISTING TABLES --
-----------------------------

ALTER TABLE l_area_area ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_area_artist ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_area_label ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_area_place ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_area_recording ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_area_release ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_area_release_group ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_area_url ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_area_work ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_artist_artist ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_artist_label ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_artist_place ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_artist_recording ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_artist_release ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_artist_release_group ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_artist_url ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_artist_work ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_label_label ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_label_place ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_label_recording ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_label_release ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_label_release_group ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_label_url ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_label_work ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_place_place ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_place_recording ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_place_release ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_place_release_group ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_place_url ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_place_work ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_recording_recording ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_recording_release ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_recording_release_group ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_recording_url ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_recording_work ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_release_release ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_release_release_group ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_release_url ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_release_work ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_release_group_release_group ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_release_group_url ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_release_group_work ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_url_url ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_url_work ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);
ALTER TABLE l_work_work ADD COLUMN link_order INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0);

COMMIT;
