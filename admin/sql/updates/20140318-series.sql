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
    id                  SERIAL, -- PK
    name                TEXT NOT NULL,
    parent              INTEGER, -- references series_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT
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

CREATE TABLE documentation.l_area_series_example
(
    id                  INTEGER NOT NULL, -- PK, references musicbrainz.l_area_series.id
    published           BOOLEAN NOT NULL,
    name                TEXT NOT NULL
);

CREATE TABLE documentation.l_artist_series_example
(
    id                  INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_series.id
    published           BOOLEAN NOT NULL,
    name                TEXT NOT NULL
);

CREATE TABLE documentation.l_instrument_series_example
(
    id                  INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_series.id
    published           BOOLEAN NOT NULL,
    name                TEXT NOT NULL
);

CREATE TABLE documentation.l_label_series_example
(
    id                  INTEGER NOT NULL, -- PK, references musicbrainz.l_label_series.id
    published           BOOLEAN NOT NULL,
    name                TEXT NOT NULL
);

CREATE TABLE documentation.l_place_series_example
(
    id                  INTEGER NOT NULL, -- PK, references musicbrainz.l_place_series.id
    published           BOOLEAN NOT NULL,
    name                TEXT NOT NULL
);

CREATE TABLE documentation.l_recording_series_example
(
    id                  INTEGER NOT NULL, -- PK, references musicbrainz.l_recording_series.id
    published           BOOLEAN NOT NULL,
    name                TEXT NOT NULL
);

CREATE TABLE documentation.l_release_series_example
(
    id                  INTEGER NOT NULL, -- PK, references musicbrainz.l_release_series.id
    published           BOOLEAN NOT NULL,
    name                TEXT NOT NULL
);

CREATE TABLE documentation.l_release_group_series_example
(
    id                  INTEGER NOT NULL, -- PK, references musicbrainz.l_release_group_series.id
    published           BOOLEAN NOT NULL,
    name                TEXT NOT NULL
);

CREATE TABLE documentation.l_series_series_example
(
    id                  INTEGER NOT NULL, -- PK, references musicbrainz.l_series_series.id
    published           BOOLEAN NOT NULL,
    name                TEXT NOT NULL
);

CREATE TABLE documentation.l_series_url_example
(
    id                  INTEGER NOT NULL, -- PK, references musicbrainz.l_series_url.id
    published           BOOLEAN NOT NULL,
    name                TEXT NOT NULL
);

CREATE TABLE documentation.l_series_work_example
(
    id                  INTEGER NOT NULL, -- PK, references musicbrainz.l_series_work.id
    published           BOOLEAN NOT NULL,
    name                TEXT NOT NULL
);

CREATE TABLE edit_series
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    series              INTEGER NOT NULL  -- PK, references series.id CASCADE
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

CREATE TABLE l_instrument_series
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
    SELECT entity0 AS recording,
           entity1 AS series,
           lrs.id AS relationship,
           link_order,
           lrs.link,
           COALESCE(text_value, '') AS text_value
    FROM l_recording_series lrs
    JOIN series s ON s.id = lrs.entity1
    JOIN link l ON l.id = lrs.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = 'ea6f0698-6782-30d6-b16d-293081b66774')
    LEFT OUTER JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

CREATE OR REPLACE VIEW release_series AS
    SELECT entity0 AS release,
           entity1 AS series,
           lrs.id AS relationship,
           link_order,
           lrs.link,
           COALESCE(text_value, '') AS text_value
    FROM l_release_series lrs
    JOIN series s ON s.id = lrs.entity1
    JOIN link l ON l.id = lrs.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = '3fa29f01-8e13-3e49-9b0a-ad212aa2f81d')
    LEFT OUTER JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

CREATE OR REPLACE VIEW release_group_series AS
    SELECT entity0 AS release_group,
           entity1 AS series,
           lrgs.id AS relationship,
           link_order,
           lrgs.link,
           COALESCE(text_value, '') AS text_value
    FROM l_release_group_series lrgs
    JOIN series s ON s.id = lrgs.entity1
    JOIN link l ON l.id = lrgs.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = '01018437-91d8-36b9-bf89-3f885d53b5bd')
    LEFT OUTER JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

CREATE OR REPLACE VIEW work_series AS
    SELECT entity1 AS work,
           entity0 AS series,
           lsw.id AS relationship,
           link_order,
           lsw.link,
           COALESCE(text_value, '') AS text_value
    FROM l_series_work lsw
    JOIN series s ON s.id = lsw.entity0
    JOIN link l ON l.id = lsw.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0')
    LEFT OUTER JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

-------------------------
-- INSERT INITIAL DATA --
-------------------------

-- new relationship types
SELECT setval('link_type_id_seq', (SELECT MAX(id) FROM link_type));
SELECT setval('link_attribute_type_id_seq', (SELECT MAX(id) FROM link_attribute_type));

INSERT INTO link_type (gid, entity_type0, entity_type1, entity0_cardinality, entity1_cardinality, name, description, link_phrase, reverse_link_phrase, long_link_phrase) VALUES
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/recording/series/part_of'), 'recording', 'series', 0, 0, 'part of', 'Indicates that the recording is part of a series.', 'parts', 'part of', 'is a part of'),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/release/series/part_of'), 'release', 'series', 0, 0, 'part of', 'Indicates that the release is part of a series.', 'part of', 'parts', 'is a part of'),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/release_group/series/part_of'), 'release_group', 'series', 0, 0, 'part of', 'Indicates that the release group is part of a series.', 'part of', 'parts', 'is a part of'),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/series/work/part_of'), 'series', 'work', 0, 0, 'part of', 'Indicates that the work is part of a series.', 'parts', 'part of', 'has part'),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/series/url/wikipedia'), 'series', 'url', 0, 0, 'wikipedia', 'Points to the Wikipedia page for this series.', 'Wikipedia', 'Wikipedia page for', 'has a Wikipedia page at')
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

INSERT INTO link_attribute_type (root, child_order, gid, name, description) VALUES
    (currval('link_attribute_type_id_seq'), 0, generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linkattributetype/ordering'), 'ordering', 'This attribute indicates the number of a work in a series.');

INSERT INTO link_attribute_type (root, parent, child_order, gid, name, description) VALUES
    ((SELECT id FROM link_attribute_type WHERE gid = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'), (SELECT id FROM link_attribute_type WHERE gid = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'), 0, generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linkattributetype/catalog_number'), 'catalog number', 'This attribute indicates the catalog number of a work in a series.'),
    ((SELECT id FROM link_attribute_type WHERE gid = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'), (SELECT id FROM link_attribute_type WHERE gid = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'), 1, generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linkattributetype/part_number'), 'part number', 'This attribute indicates the part number of a work in a series.'),
    ((SELECT id FROM link_attribute_type WHERE gid = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'), (SELECT id FROM link_attribute_type WHERE gid = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'), 2, generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linkattributetype/volume_number'), 'volume number', 'This attribute indicates the volume number of a work in a series.');

INSERT INTO link_text_attribute_type (SELECT id FROM link_attribute_type WHERE gid IN ('a59c5830-5ec7-38fe-9a21-c7ea54f6650a', '09b75382-a924-3f40-9106-f9e0dc4105e4', '7dbc466d-247c-32db-888a-39febeaed913', '74d83d55-7a84-33e0-a1e0-163f9c75d96e'));

INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max) VALUES
    ((SELECT id FROM link_type WHERE gid = 'ea6f0698-6782-30d6-b16d-293081b66774'), (SELECT id FROM link_attribute_type WHERE gid = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'), 0, 1),
    ((SELECT id FROM link_type WHERE gid = '3fa29f01-8e13-3e49-9b0a-ad212aa2f81d'), (SELECT id FROM link_attribute_type WHERE gid = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'), 0, 1),
    ((SELECT id FROM link_type WHERE gid = '01018437-91d8-36b9-bf89-3f885d53b5bd'), (SELECT id FROM link_attribute_type WHERE gid = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'), 0, 1),
    ((SELECT id FROM link_type WHERE gid = 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0'), (SELECT id FROM link_attribute_type WHERE gid = 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'), 0, 1);

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

--------------------
-- CREATE INDEXES --
--------------------

ALTER TABLE documentation.l_area_series_example ADD CONSTRAINT l_area_series_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_artist_series_example ADD CONSTRAINT l_artist_series_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_instrument_series_example ADD CONSTRAINT l_instrument_series_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_label_series_example ADD CONSTRAINT l_label_series_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_place_series_example ADD CONSTRAINT l_place_series_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_recording_series_example ADD CONSTRAINT l_recording_series_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_release_group_series_example ADD CONSTRAINT l_release_group_series_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_release_series_example ADD CONSTRAINT l_release_series_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_series_series_example ADD CONSTRAINT l_series_series_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_series_url_example ADD CONSTRAINT l_series_url_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_series_work_example ADD CONSTRAINT l_series_work_example_pkey PRIMARY KEY (id);
ALTER TABLE editor_subscribe_series ADD CONSTRAINT editor_subscribe_series_pkey PRIMARY KEY (id);
ALTER TABLE editor_subscribe_series_deleted ADD CONSTRAINT editor_subscribe_series_deleted_pkey PRIMARY KEY (editor, gid);

ALTER TABLE l_area_series ADD CONSTRAINT l_area_series_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_series ADD CONSTRAINT l_artist_series_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_series ADD CONSTRAINT l_instrument_series_pkey PRIMARY KEY (id);
ALTER TABLE l_label_series ADD CONSTRAINT l_label_series_pkey PRIMARY KEY (id);
ALTER TABLE l_place_series ADD CONSTRAINT l_place_series_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_series ADD CONSTRAINT l_recording_series_pkey PRIMARY KEY (id);
ALTER TABLE l_release_group_series ADD CONSTRAINT l_release_group_series_pkey PRIMARY KEY (id);
ALTER TABLE l_release_series ADD CONSTRAINT l_release_series_pkey PRIMARY KEY (id);
ALTER TABLE l_series_series ADD CONSTRAINT l_series_series_pkey PRIMARY KEY (id);
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

DROP INDEX IF EXISTS l_area_area_idx_uniq;
DROP INDEX IF EXISTS l_area_artist_idx_uniq;
DROP INDEX IF EXISTS l_area_instrument_idx_uniq;
DROP INDEX IF EXISTS l_area_label_idx_uniq;
DROP INDEX IF EXISTS l_area_place_idx_uniq;
DROP INDEX IF EXISTS l_area_recording_idx_uniq;
DROP INDEX IF EXISTS l_area_release_idx_uniq;
DROP INDEX IF EXISTS l_area_release_group_idx_uniq;
DROP INDEX IF EXISTS l_area_series_idx_uniq;
DROP INDEX IF EXISTS l_area_url_idx_uniq;
DROP INDEX IF EXISTS l_area_work_idx_uniq;

DROP INDEX IF EXISTS l_artist_artist_idx_uniq;
DROP INDEX IF EXISTS l_artist_instrument_idx_uniq;
DROP INDEX IF EXISTS l_artist_label_idx_uniq;
DROP INDEX IF EXISTS l_artist_place_idx_uniq;
DROP INDEX IF EXISTS l_artist_recording_idx_uniq;
DROP INDEX IF EXISTS l_artist_release_idx_uniq;
DROP INDEX IF EXISTS l_artist_release_group_idx_uniq;
DROP INDEX IF EXISTS l_artist_series_idx_uniq;
DROP INDEX IF EXISTS l_artist_url_idx_uniq;
DROP INDEX IF EXISTS l_artist_work_idx_uniq;

DROP INDEX IF EXISTS l_instrument_instrument_idx_uniq;
DROP INDEX IF EXISTS l_instrument_label_idx_uniq;
DROP INDEX IF EXISTS l_instrument_place_idx_uniq;
DROP INDEX IF EXISTS l_instrument_recording_idx_uniq;
DROP INDEX IF EXISTS l_instrument_release_idx_uniq;
DROP INDEX IF EXISTS l_instrument_release_group_idx_uniq;
DROP INDEX IF EXISTS l_instrument_series_idx_uniq;
DROP INDEX IF EXISTS l_instrument_url_idx_uniq;
DROP INDEX IF EXISTS l_instrument_work_idx_uniq;

DROP INDEX IF EXISTS l_label_label_idx_uniq;
DROP INDEX IF EXISTS l_label_place_idx_uniq;
DROP INDEX IF EXISTS l_label_recording_idx_uniq;
DROP INDEX IF EXISTS l_label_release_idx_uniq;
DROP INDEX IF EXISTS l_label_release_group_idx_uniq;
DROP INDEX IF EXISTS l_label_series_idx_uniq;
DROP INDEX IF EXISTS l_label_url_idx_uniq;
DROP INDEX IF EXISTS l_label_work_idx_uniq;

DROP INDEX IF EXISTS l_place_place_idx_uniq;
DROP INDEX IF EXISTS l_place_recording_idx_uniq;
DROP INDEX IF EXISTS l_place_release_idx_uniq;
DROP INDEX IF EXISTS l_place_release_group_idx_uniq;
DROP INDEX IF EXISTS l_place_series_idx_uniq;
DROP INDEX IF EXISTS l_place_url_idx_uniq;
DROP INDEX IF EXISTS l_place_work_idx_uniq;

DROP INDEX IF EXISTS l_recording_recording_idx_uniq;
DROP INDEX IF EXISTS l_recording_release_idx_uniq;
DROP INDEX IF EXISTS l_recording_release_group_idx_uniq;
DROP INDEX IF EXISTS l_recording_series_idx_uniq;
DROP INDEX IF EXISTS l_recording_url_idx_uniq;
DROP INDEX IF EXISTS l_recording_work_idx_uniq;

DROP INDEX IF EXISTS l_release_release_idx_uniq;
DROP INDEX IF EXISTS l_release_release_group_idx_uniq;
DROP INDEX IF EXISTS l_release_series_idx_uniq;
DROP INDEX IF EXISTS l_release_url_idx_uniq;
DROP INDEX IF EXISTS l_release_work_idx_uniq;

DROP INDEX IF EXISTS l_release_group_release_group_idx_uniq;
DROP INDEX IF EXISTS l_release_group_series_idx_uniq;
DROP INDEX IF EXISTS l_release_group_url_idx_uniq;
DROP INDEX IF EXISTS l_release_group_work_idx_uniq;

DROP INDEX IF EXISTS l_series_series_idx_uniq;
DROP INDEX IF EXISTS l_series_url_idx_uniq;
DROP INDEX IF EXISTS l_series_work_idx_uniq;

DROP INDEX IF EXISTS l_url_url_idx_uniq;
DROP INDEX IF EXISTS l_url_work_idx_uniq;

DROP INDEX IF EXISTS l_work_work_idx_uniq;

CREATE UNIQUE INDEX l_area_area_idx_uniq ON l_area_area (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_artist_idx_uniq ON l_area_artist (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_instrument_idx_uniq ON l_area_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_label_idx_uniq ON l_area_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_place_idx_uniq ON l_area_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_recording_idx_uniq ON l_area_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_release_idx_uniq ON l_area_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_release_group_idx_uniq ON l_area_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_series_idx_uniq ON l_area_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_url_idx_uniq ON l_area_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_work_idx_uniq ON l_area_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_artist_artist_idx_uniq ON l_artist_artist (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_instrument_idx_uniq ON l_artist_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_label_idx_uniq ON l_artist_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_place_idx_uniq ON l_artist_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_recording_idx_uniq ON l_artist_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_release_idx_uniq ON l_artist_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_release_group_idx_uniq ON l_artist_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_series_idx_uniq ON l_artist_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_url_idx_uniq ON l_artist_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_work_idx_uniq ON l_artist_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_instrument_instrument_idx_uniq ON l_instrument_instrument (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_label_idx_uniq ON l_instrument_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_place_idx_uniq ON l_instrument_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_recording_idx_uniq ON l_instrument_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_release_idx_uniq ON l_instrument_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_release_group_idx_uniq ON l_instrument_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_series_idx_uniq ON l_instrument_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_url_idx_uniq ON l_instrument_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_work_idx_uniq ON l_instrument_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_label_label_idx_uniq ON l_label_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_place_idx_uniq ON l_label_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_recording_idx_uniq ON l_label_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_release_idx_uniq ON l_label_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_release_group_idx_uniq ON l_label_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_series_idx_uniq ON l_label_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_url_idx_uniq ON l_label_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_work_idx_uniq ON l_label_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_place_place_idx_uniq ON l_place_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_place_recording_idx_uniq ON l_place_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_place_release_idx_uniq ON l_place_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_place_release_group_idx_uniq ON l_place_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_place_series_idx_uniq ON l_place_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_place_url_idx_uniq ON l_place_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_place_work_idx_uniq ON l_place_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_recording_recording_idx_uniq ON l_recording_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_recording_release_idx_uniq ON l_recording_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_recording_release_group_idx_uniq ON l_recording_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_recording_series_idx_uniq ON l_recording_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_recording_url_idx_uniq ON l_recording_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_recording_work_idx_uniq ON l_recording_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_release_release_idx_uniq ON l_release_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_release_group_idx_uniq ON l_release_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_series_idx_uniq ON l_release_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_url_idx_uniq ON l_release_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_work_idx_uniq ON l_release_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_release_group_release_group_idx_uniq ON l_release_group_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_group_series_idx_uniq ON l_release_group_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_group_url_idx_uniq ON l_release_group_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_group_work_idx_uniq ON l_release_group_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_series_series_idx_uniq ON l_series_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_series_url_idx_uniq ON l_series_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_series_work_idx_uniq ON l_series_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_url_url_idx_uniq ON l_url_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_url_work_idx_uniq ON l_url_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_work_work_idx_uniq ON l_work_work (entity0, entity1, link, link_order);

CREATE INDEX l_area_series_idx_entity1 ON l_area_series (entity1);
CREATE INDEX l_artist_series_idx_entity1 ON l_artist_series (entity1);
CREATE INDEX l_label_series_idx_entity1 ON l_label_series (entity1);
CREATE INDEX l_place_series_idx_entity1 ON l_place_series (entity1);
CREATE INDEX l_recording_series_idx_entity1 ON l_recording_series (entity1);
CREATE INDEX l_release_series_idx_entity1 ON l_release_series (entity1);
CREATE INDEX l_release_group_series_idx_entity1 ON l_release_group_series (entity1);
CREATE INDEX l_series_series_idx_entity1 ON l_series_series (entity1);
CREATE INDEX l_series_url_idx_entity1 ON l_series_url (entity1);
CREATE INDEX l_series_work_idx_entity1 ON l_series_work (entity1);

CREATE UNIQUE INDEX series_idx_gid ON series (gid);
CREATE INDEX series_idx_name ON series (name);

CREATE INDEX series_alias_idx_series ON series_alias (series);
CREATE UNIQUE INDEX series_alias_idx_primary ON series_alias (series, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX series_idx_txt ON series USING gin(to_tsvector('mb_simple', name));

CREATE INDEX series_alias_idx_txt ON series_alias USING gin(to_tsvector('mb_simple', name));
CREATE INDEX series_alias_idx_txt_sort ON series_alias USING gin(to_tsvector('mb_simple', sort_name));

--------------------------
-- CREATE NEW FUNCTIONS --
--------------------------

CREATE OR REPLACE FUNCTION natural_series_sort(integer[], text[])
RETURNS TABLE (relationship integer, text_value text, link_order integer) AS $$
    my ($relationships, $text_values) = @_;

    die "array lengths differ" if @$relationships != @$text_values;

    my %relationships_by_text_value;
    for (my $i = 0; $i < @$relationships; $i++) {
        $relationships_by_text_value{$text_values->[$i]} = $relationships->[$i];
    }

    my @sorted_values = map { $_->[0] } sort {
        my ($a_parts, $b_parts) = ($a->[1], $b->[1]);

        my $max = @$a_parts <= @$b_parts ? @$a_parts : @$b_parts;
        my $order = 0;

        # Use <= and replace undef values with the empty string, so that
        # A1 sorts before A1B1.
        for (my $i = 0; $i <= $max; $i++) {
            my ($a_part, $b_part) = ($a_parts->[$i] // '', $b_parts->[$i] // '');

            my ($a_num, $b_num) = map { $_ =~ /^\d+$/ } ($a_part, $b_part);

            $order = $a_num && $b_num ? ($a_part <=> $b_part) : ($a_part cmp $b_part);
            last if $order;
        }

        $order;
    } map { [$_, [split /(\d+)/, $_]] } keys %relationships_by_text_value;

    my @result_table;
    for (my $i = 0; $i < @sorted_values; $i++) {
        my $text_value = $sorted_values[$i];

        push @result_table, {
            relationship => $relationships_by_text_value{$text_value},
            text_value => $text_value,
            link_order => $i+1,
        };
    }

    return \@result_table;
$$ LANGUAGE plperl IMMUTABLE;

CREATE OR REPLACE FUNCTION a_ins_l_recording_series() RETURNS trigger AS $$
BEGIN
    PERFORM reorder_automatic_series(NEW.entity1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_l_recording_series() RETURNS trigger AS $$
BEGIN
    IF OLD.entity1 != NEW.entity1 THEN
        PERFORM reorder_automatic_series(OLD.entity1);
    END IF;
    IF OLD.entity1 != NEW.entity1 OR OLD.link != NEW.link THEN
        PERFORM reorder_automatic_series(NEW.entity1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_l_recording_series() RETURNS trigger AS $$
BEGIN
    PERFORM reorder_automatic_series(OLD.entity1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_l_release_series() RETURNS trigger AS $$
BEGIN
    PERFORM reorder_automatic_series(NEW.entity1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_l_release_series() RETURNS trigger AS $$
BEGIN
    IF OLD.entity1 != NEW.entity1 THEN
        PERFORM reorder_automatic_series(OLD.entity1);
    END IF;
    IF OLD.entity1 != NEW.entity1 OR OLD.link != NEW.link THEN
        PERFORM reorder_automatic_series(NEW.entity1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_l_release_series() RETURNS trigger AS $$
BEGIN
    PERFORM reorder_automatic_series(OLD.entity1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_l_release_group_series() RETURNS trigger AS $$
BEGIN
    PERFORM reorder_automatic_series(NEW.entity1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_l_release_group_series() RETURNS trigger AS $$
BEGIN
    IF OLD.entity1 != NEW.entity1 THEN
        PERFORM reorder_automatic_series(OLD.entity1);
    END IF;
    IF OLD.entity1 != NEW.entity1 OR OLD.link != NEW.link THEN
        PERFORM reorder_automatic_series(NEW.entity1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_l_release_group_series() RETURNS trigger AS $$
BEGIN
    PERFORM reorder_automatic_series(OLD.entity1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_l_series_work() RETURNS trigger AS $$
BEGIN
    PERFORM reorder_automatic_series(NEW.entity0);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_l_series_work() RETURNS trigger AS $$
BEGIN
    IF OLD.entity0 != NEW.entity0 THEN
        PERFORM reorder_automatic_series(OLD.entity1);
    END IF;
    IF OLD.entity0 != NEW.entity0 OR OLD.link != NEW.link THEN
        PERFORM reorder_automatic_series(NEW.entity0);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_l_series_work() RETURNS trigger AS $$
BEGIN
    PERFORM reorder_automatic_series(OLD.entity0);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_series() RETURNS trigger AS $$
BEGIN
    IF OLD.ordering_type != NEW.ordering_type AND NEW.ordering_type = 1 THEN
        PERFORM reorder_automatic_series(NEW.id);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION reorder_automatic_series(series_id integer) RETURNS void AS $$
DECLARE
    entity_type_name text;
BEGIN
    IF NOT EXISTS (SELECT true FROM series s WHERE s.id = series_id AND s.ordering_type = 1) THEN
        RETURN;
    END IF;

    SELECT entity_type FROM series_type st JOIN series s ON st.id = s.type
    INTO entity_type_name;

    EXECUTE format('
        WITH unzipped AS (
            SELECT array_agg(relationship) AS relationships,
                   array_agg(text_value) AS text_values FROM %1$I_series es
            WHERE es.series = $1
        ),
        sorted_series (tuple) AS (
            SELECT natural_series_sort(relationships, text_values) FROM unzipped
        )
        UPDATE %2$I SET link_order = (sorted_series.tuple).link_order FROM sorted_series
        WHERE id = (sorted_series.tuple).relationship;',
        entity_type_name,
        format(CASE WHEN entity_type_name < 'series'
                    THEN 'l_%s_series' ELSE 'l_series_%s' END, entity_type_name)
    ) USING series_id;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
