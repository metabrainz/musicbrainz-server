BEGIN;

-----------------------
-- CREATE NEW TABLES --
-----------------------
CREATE TABLE location_name (id SERIAL PRIMARY KEY, name VARCHAR NOT NULL);

CREATE TABLE area_type (id SERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL);
                                               -- e.g. 'country', 'province'

CREATE TABLE area (id                SERIAL PRIMARY KEY,
                   gid               uuid NOT NULL,
                   name              INTEGER NOT NULL REFERENCES location_name(id),
                   sort_name         INTEGER NOT NULL references location_name(id),
                   type              INTEGER REFERENCES area_type(id),
                   edits_pending     INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
                   last_updated      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                   begin_date_year   SMALLINT,
                   begin_date_month  SMALLINT,
                   begin_date_day    SMALLINT,
                   end_date_year     SMALLINT,
                   end_date_month    SMALLINT,
                   end_date_day      SMALLINT);

CREATE TABLE area_code_type (id    SERIAL PRIMARY KEY,
                             name  VARCHAR(255) NOT NULL);
                             -- e.g. ISO-3166-1
CREATE TABLE area_code (area       INTEGER NOT NULL REFERENCES area(id),
                        code       VARCHAR(30) NOT NULL,
                        code_type  INTEGER NOT NULL REFERENCES area_code_type(id),
             CONSTRAINT area_code_pkey
                 PRIMARY KEY (area, code, code_type));

-- aliases
CREATE TABLE area_alias_type (id SERIAL PRIMARY KEY, name TEXT NOT NULL);
CREATE TABLE area_alias (id                  SERIAL PRIMARY KEY,
                         area                INTEGER NOT NULL REFERENCES area(id),
                         name                INTEGER NOT NULL REFERENCES location_name(id),
                         locale              TEXT,
                         edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
                         last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                         type                INTEGER REFERENCES area_alias_type(id),
                         sort_name           INTEGER NOT NULL references location_name(id),
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
CREATE TABLE area_annotation (area        INTEGER NOT NULL REFERENCES area(id),
                              annotation  INTEGER NOT NULL REFERENCES annotation(id),
             CONSTRAINT area_annotation_pkey
                 PRIMARY KEY (area, annotation));

-- relationships
CREATE TABLE l_area_area
(
    id                  SERIAL,
    link                INTEGER NOT NULL REFERENCES link(id),
    entity0             INTEGER NOT NULL REFERENCES area(id),
    entity1             INTEGER NOT NULL REFERENCES area(id),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_artist
(
    id                  SERIAL,
    link                INTEGER NOT NULL REFERENCES link(id),
    entity0             INTEGER NOT NULL REFERENCES area(id),
    entity1             INTEGER NOT NULL REFERENCES artist(id),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_label
(
    id                  SERIAL,
    link                INTEGER NOT NULL REFERENCES link(id),
    entity0             INTEGER NOT NULL REFERENCES area(id),
    entity1             INTEGER NOT NULL REFERENCES label(id),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL REFERENCES link(id),
    entity0             INTEGER NOT NULL REFERENCES area(id),
    entity1             INTEGER NOT NULL REFERENCES work(id),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL REFERENCES link(id),
    entity0             INTEGER NOT NULL REFERENCES area(id),
    entity1             INTEGER NOT NULL REFERENCES url(id),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_recording
(
    id                  SERIAL,
    link                INTEGER NOT NULL REFERENCES link(id),
    entity0             INTEGER NOT NULL REFERENCES area(id),
    entity1             INTEGER NOT NULL REFERENCES recording(id),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL REFERENCES link(id),
    entity0             INTEGER NOT NULL REFERENCES area(id),
    entity1             INTEGER NOT NULL REFERENCES release_group(id),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_area_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL REFERENCES link(id),
    entity0             INTEGER NOT NULL REFERENCES area(id),
    entity1             INTEGER NOT NULL REFERENCES release(id),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-------------------------
-- INSERT INITIAL DATA --
-------------------------

-- basic types
INSERT INTO area_code_type (id, name) VALUES (1, 'ISO 3166-1'), (2, 'ISO 3166-2'), (3, 'ISO 3166-3') RETURNING *;
INSERT INTO area_type (id, name) VALUES (1, 'Country') RETURNING *;

-- migrate country table
INSERT INTO location_name (id, name) SELECT id, name FROM country;

INSERT INTO area (id, gid, name, sort_name, type)
  SELECT id,
         generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/country/' || id) AS gid,
         -- ^ totally fabricated URI just for this migration. *shrug*
         id AS name,
         id AS sort_name,
         1::integer AS type
    FROM country;

INSERT INTO area_code (code, area, code_type)
  SELECT iso_code AS code,
         id AS area,
         1::integer AS code_type
    FROM country;

-- new relationship types
INSERT INTO link_type (gid, entity_type0, entity_type1, name, description, link_phrase, reverse_link_phrase, short_link_phrase) VALUES
  (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/area/url/wikipedia'), 'area', 'url', 'wikipedia', 'Points to the Wikipedia page for this area. (<a href="http://musicbrainz.org/doc/Wikipedia_Relationship_Type">Details</a>)', 'Wikipedia', 'Wikipedia page for', 'has a Wikipedia page at'),
  (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/area/area/part_of'), 'area', 'area', 'part of', '', 'parts', 'part of', 'has part'),

  (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/area/label/based_in'), 'area', 'label', 'based in', '', 'labels', 'Location', 'is location for')
  RETURNING id, gid, entity_type0, entity_type1, name, short_link_phrase;

-- location editors
UPDATE editor SET privs = privs | 256 WHERE id IN (53705, 326637, 295208) RETURNING name, CASE privs & 256 WHEN 256 THEN 'is now a location editor' ELSE 'not given permissions' END;
                                                -- nikki, reotab, ianmcorvidae

--------------------
-- CREATE INDEXES --
--------------------

CREATE UNIQUE INDEX location_name_idx_name ON location_name (name);

CREATE UNIQUE INDEX area_idx_gid ON area (gid);
CREATE INDEX area_idx_name ON area (name);
CREATE INDEX area_idx_sort_name ON area (sort_name);

CREATE INDEX area_code_idx_code ON area_code (code);
CREATE INDEX area_code_idx_area ON area_code (area);
CREATE UNIQUE INDEX area_code_idx_code_type ON area_code (code, code_type);

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

-----------------------------
-- MIGRATE EXISTING TABLES --
-----------------------------

-- releases
ALTER TABLE release DROP CONSTRAINT release_fk_country,
                    ADD CONSTRAINT release_fk_area FOREIGN KEY (country) REFERENCES area(id);

-- editors
ALTER TABLE editor RENAME COLUMN country TO area;
ALTER TABLE editor DROP CONSTRAINT editor_fk_country,
                   ADD CONSTRAINT editor_fk_area FOREIGN KEY (area) REFERENCES area(id);

-- labels
-- TODO make sure the name in the next few rows is correct after adding types
INSERT INTO link (link_type) SELECT id FROM link_type WHERE name = 'based in' and entity_type0 = 'area' and entity_type1 = 'label';
INSERT INTO l_area_label (link, entity0, entity1)
   SELECT
     (SELECT id FROM link WHERE link_type IN (SELECT id FROM link_type WHERE name = 'based in' and entity_type0 = 'area' and entity_type1 = 'label')) AS link,
     country AS entity0,
     id AS entity1
   FROM label WHERE country IS NOT NULL;

ALTER TABLE label DROP CONSTRAINT label_fk_country;
ALTER TABLE label DROP COLUMN country;

-- artists
ALTER TABLE artist DROP CONSTRAINT artist_fk_country,
                   ADD CONSTRAINT artist_fk_area FOREIGN KEY (country) REFERENCES area(id);
ALTER TABLE artist ADD COLUMN begin_area integer REFERENCES area(id);
ALTER TABLE artist ADD COLUMN end_area integer REFERENCES area(id);

-- remove country table
DROP TABLE country;

ROLLBACK;
