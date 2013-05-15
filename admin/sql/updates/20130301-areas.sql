\set ON_ERROR_STOP 1
BEGIN;

-----------------------
-- CREATE NEW TABLES --
-----------------------
CREATE TABLE area_type (id SERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL);
                                               -- e.g. 'country', 'province'

CREATE TABLE area (id                SERIAL PRIMARY KEY,
                   gid               uuid NOT NULL,
                   name              VARCHAR NOT NULL,
                   sort_name         VARCHAR NOT NULL,
                   type              INTEGER,
                   edits_pending     INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
                   last_updated      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                   begin_date_year   SMALLINT,
                   begin_date_month  SMALLINT,
                   begin_date_day    SMALLINT,
                   end_date_year     SMALLINT,
                   end_date_month    SMALLINT,
                   end_date_day      SMALLINT,
                   ended             BOOLEAN NOT NULL DEFAULT FALSE
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
                   ));

CREATE TABLE area_gid_redirect (
    gid UUID NOT NULL PRIMARY KEY,
    new_id INTEGER NOT NULL,
    created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


CREATE TABLE iso_3166_1 (area      INTEGER NOT NULL,
                         code      CHAR(2) PRIMARY KEY);

CREATE TABLE iso_3166_2 (area      INTEGER NOT NULL,
                         code      VARCHAR(10) PRIMARY KEY);

CREATE TABLE iso_3166_3 (area      INTEGER NOT NULL,
                         code      CHAR(4) PRIMARY KEY);

-- aliases
CREATE TABLE area_alias_type (id SERIAL PRIMARY KEY, name TEXT NOT NULL);
CREATE TABLE area_alias (id                  SERIAL PRIMARY KEY,
                         area                INTEGER NOT NULL,
                         name                VARCHAR NOT NULL,
                         locale              TEXT,
                         edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
                         last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                         type                INTEGER,
                         sort_name           VARCHAR NOT NULL,
                         begin_date_year     SMALLINT,
                         begin_date_month    SMALLINT,
                         begin_date_day      SMALLINT,
                         end_date_year       SMALLINT,
                         end_date_month      SMALLINT,
                         end_date_day        SMALLINT,
                         primary_for_locale  BOOLEAN NOT NULL DEFAULT false,
             CONSTRAINT primary_check
                 CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL)));

-- annotation
CREATE TABLE area_annotation (area        INTEGER NOT NULL,
                              annotation  INTEGER NOT NULL,
             CONSTRAINT area_annotation_pkey
                 PRIMARY KEY (area, annotation));

-- relationships
CREATE TABLE l_area_area
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_artist
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_label
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_recording
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL,
    entity0             INTEGER NOT NULL,
    entity1             INTEGER NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- release migration
CREATE TABLE country_area
(
    area                INTEGER PRIMARY KEY
);

-------------------------
-- INSERT INITIAL DATA --
-------------------------

-- basic types
INSERT INTO area_type (id, name) VALUES (1, 'Country') RETURNING *;

-- migrate country table
INSERT INTO area (id, gid, name, sort_name, type)
  SELECT id,
         generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/country/' || id) AS gid,
         -- ^ totally fabricated URI just for this migration. *shrug*
         name AS name,
         name AS sort_name,
         1::integer AS type
    FROM country;

INSERT INTO country_area (area) SELECT id FROM country;

INSERT INTO iso_3166_1 (code, area)
  SELECT iso_code AS code,
         id AS area
    FROM country;

-- new relationship types
INSERT INTO link_type (gid, entity_type0, entity_type1, name, description, link_phrase, reverse_link_phrase, long_link_phrase) VALUES
  (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/area/url/wikipedia'), 'area', 'url', 'wikipedia', 'Points to the Wikipedia page for this area. (<a href="http://musicbrainz.org/doc/Wikipedia_Relationship_Type">Details</a>)', 'Wikipedia', 'Wikipedia page for', 'has a Wikipedia page at'),

  (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/area/area/part_of'), 'area', 'area', 'part of', 'Designates that one area is contained by another.', 'parts', 'part of', 'has part'),

  (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/area/work/anthem'), 'area', 'work', 'anthem', 'Designates that a work is or was the anthem for an area', 'anthem of', 'anthem', 'is the anthem of')
  RETURNING id, gid, entity_type0, entity_type1, name, long_link_phrase;

-- location editors
UPDATE editor SET privs = privs | 256 WHERE name IN ('nikki', 'reosarevok', 'ianmcorvidae') RETURNING name, CASE privs & 256 WHEN 256 THEN 'is now a location editor' ELSE 'not given permissions' END;

--------------------
-- CREATE INDEXES --
--------------------

ALTER TABLE l_area_area ADD CONSTRAINT l_area_area_pkey PRIMARY KEY (id);
ALTER TABLE l_area_artist ADD CONSTRAINT l_area_artist_pkey PRIMARY KEY (id);
ALTER TABLE l_area_label ADD CONSTRAINT l_area_label_pkey PRIMARY KEY (id);
ALTER TABLE l_area_recording ADD CONSTRAINT l_area_recording_pkey PRIMARY KEY (id);
ALTER TABLE l_area_release ADD CONSTRAINT l_area_release_pkey PRIMARY KEY (id);
ALTER TABLE l_area_release_group ADD CONSTRAINT l_area_release_group_pkey PRIMARY KEY (id);
ALTER TABLE l_area_url ADD CONSTRAINT l_area_url_pkey PRIMARY KEY (id);
ALTER TABLE l_area_work ADD CONSTRAINT l_area_work_pkey PRIMARY KEY (id);

CREATE UNIQUE INDEX area_idx_gid ON area (gid);
CREATE INDEX area_idx_page ON area (page_index(name));
CREATE INDEX area_idx_name ON area (name);
CREATE INDEX area_idx_sort_name ON area (sort_name);

CREATE INDEX iso_3166_1_idx_area ON iso_3166_1 (area);
CREATE INDEX iso_3166_2_idx_area ON iso_3166_2 (area);
CREATE INDEX iso_3166_3_idx_area ON iso_3166_3 (area);

CREATE INDEX area_alias_idx_area ON area_alias (area);
CREATE UNIQUE INDEX area_alias_idx_primary ON area_alias (area, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE UNIQUE INDEX l_area_area_idx_uniq ON l_area_area (entity0, entity1, link);
CREATE UNIQUE INDEX l_area_artist_idx_uniq ON l_area_artist (entity0, entity1, link);
CREATE UNIQUE INDEX l_area_label_idx_uniq ON l_area_label (entity0, entity1, link);
CREATE UNIQUE INDEX l_area_recording_idx_uniq ON l_area_recording (entity0, entity1, link);
CREATE UNIQUE INDEX l_area_release_idx_uniq ON l_area_release (entity0, entity1, link);
CREATE UNIQUE INDEX l_area_release_group_idx_uniq ON l_area_release_group (entity0, entity1, link);
CREATE UNIQUE INDEX l_area_url_idx_uniq ON l_area_url (entity0, entity1, link);
CREATE UNIQUE INDEX l_area_work_idx_uniq ON l_area_work (entity0, entity1, link);

CREATE INDEX area_idx_name_txt ON area USING gin(to_tsvector('mb_simple', name));

-----------------------------
-- MIGRATE EXISTING TABLES --
-----------------------------

-- releases
ALTER TABLE release_country DROP CONSTRAINT IF EXISTS release_country_fk_country;

-- editors
ALTER TABLE editor RENAME COLUMN country TO area;
ALTER TABLE editor DROP CONSTRAINT IF EXISTS editor_fk_country;

-- labels
ALTER TABLE label RENAME COLUMN country TO area;
ALTER TABLE label DROP CONSTRAINT IF EXISTS label_fk_country;

-- artists
ALTER TABLE artist DROP CONSTRAINT IF EXISTS artist_fk_country;
ALTER TABLE artist RENAME COLUMN country TO area;
ALTER TABLE artist ADD COLUMN begin_area integer;
ALTER TABLE artist ADD COLUMN end_area integer;

-- remove country table
DROP TABLE country;

COMMIT;
