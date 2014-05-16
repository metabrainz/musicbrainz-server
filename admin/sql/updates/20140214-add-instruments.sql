\set ON_ERROR_STOP 1

BEGIN;


CREATE TABLE instrument_type (
    id                  SERIAL, -- PK
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references instrument_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT
);

CREATE TABLE instrument (
    id                  SERIAL, -- PK
    gid                 uuid NOT NULL,
    name                VARCHAR NOT NULL,
    type                INTEGER, -- references instrument_type.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    description         TEXT NOT NULL DEFAULT ''
);

CREATE TABLE instrument_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references instrument.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE instrument_alias_type (
    id SERIAL, -- PK,
    name TEXT NOT NULL,
    parent              INTEGER, -- references instrument_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT
);

CREATE TABLE instrument_alias (
    id                  SERIAL, --PK
    instrument          INTEGER NOT NULL, -- references instrument.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references instrument_alias_type.id
    sort_name           VARCHAR NOT NULL,
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    primary_for_locale  BOOLEAN NOT NULL DEFAULT false,
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

CREATE TABLE instrument_annotation (
    instrument  INTEGER NOT NULL, -- PK, references instrument.id
    annotation  INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE edit_instrument
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    instrument          INTEGER NOT NULL  -- PK, references instrument.id CASCADE
);

CREATE TABLE l_area_instrument
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references instrument.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_artist_instrument
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references instrument.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_instrument_label
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references label.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_instrument_instrument
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references instrument.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_instrument_place
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_instrument_recording
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_instrument_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_instrument_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_instrument_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

CREATE TABLE l_instrument_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0)
);

SELECT setval('link_id_seq', (SELECT MAX(id) FROM link));
SELECT setval('link_type_id_seq', (SELECT MAX(id) FROM link_type));
SELECT setval('url_id_seq', (SELECT MAX(id) FROM url));

INSERT INTO instrument_type (name) VALUES ('Wind instrument'), ('String instrument'), ('Percussion instrument'), ('Electronic instrument'), ('Other instrument');

INSERT INTO instrument_alias_type (name) VALUES ('Instrument name'), ('Search hint');

INSERT INTO instrument (gid, name, description) SELECT gid, name, COALESCE(description, '') FROM link_attribute_type WHERE parent IS NOT NULL AND root = 14 ORDER BY id;

INSERT INTO link_type (gid, entity_type0, entity_type1, name, description, link_phrase, reverse_link_phrase, long_link_phrase, priority) VALUES
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/instrument/url/wikipedia'), 'instrument', 'url', 'wikipedia', 'wikipedia', 'Wikipedia', 'Wikipedia', 'Wikipedia', 0),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/instrument/url/image'), 'instrument', 'url', 'image', 'image', 'image', 'image', 'image', 0),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/instrument/url/wikidata'), 'instrument', 'url', 'wikidata', 'wikidata', 'Wikidata', 'Wikidata', 'Wikidata', 0),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/instrument/url/information page'), 'instrument', 'url', 'information page', 'information page', 'information page', 'information page', 'information page', 0),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/instrument/instrument/child'), 'instrument', 'instrument', 'child', '', 'child of', 'children', 'is a child of', 0),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/instrument/instrument/type of'), 'instrument', 'instrument', 'type of', 'type of', 'type of', 'subtypes', 'is a type of', 0),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/instrument/instrument/derived from'), 'instrument', 'instrument', 'derived from', 'derived from', 'derived from', 'derivations', 'is derived from', 0),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/instrument/instrument/related to'), 'instrument', 'instrument', 'related to', 'related to', 'related to', 'related instruments', 'is related to', 0),
    (generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/linktype/instrument/instrument/parts'), 'instrument', 'instrument', 'parts', 'parts', 'consists of', 'part of', 'has parts', 0);

INSERT INTO link (link_type) SELECT id FROM link_type WHERE entity_type0 = 'instrument' ORDER BY id;


-- Remove descriptions which are just the same as the name
UPDATE instrument SET description = '' WHERE description = name;
UPDATE link_attribute_type SET description = '' WHERE description = name AND root = 14;


-- Migrate URLs from instrument descriptions to URL relationships

-- 1. Insert the URLs into the url table
WITH urls AS (
    SELECT DISTINCT regexp_replace(description, '.*\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$', E'\\1') as url
    FROM link_attribute_type
    WHERE root = 14
    AND description ~ '.*\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$'
)
INSERT INTO url (gid, url)
SELECT generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', url), url
FROM urls
WHERE url NOT IN (SELECT url FROM url WHERE url = urls.url)
ORDER BY url;


-- 2. Insert relationships into l_instrument_url
INSERT INTO l_instrument_url (link, entity0, entity1)
SELECT link.id, i.id, url.id
FROM (
    SELECT l.id
    FROM link_type lt
    JOIN link l ON l.link_type = lt.id
    WHERE lt.name = 'wikipedia'
    AND lt.entity_type0 = 'instrument'
) AS link, instrument i
JOIN url ON regexp_replace(description, '.*\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$', E'\\1') = url
WHERE i.description ~ '.*\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$'
ORDER BY link.id, i.id, url.id;


-- 3. Remove the URLs from the instrument descriptions
UPDATE instrument
SET description = regexp_replace(description, ' *\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$', '')
WHERE description ~ '.*\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$';

UPDATE link_attribute_type
SET description = regexp_replace(description, ' *\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$', '')
WHERE description ~ '.*\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$'
AND root = 14;


-- Migrate aliases from instrument descriptions to instrument aliases

-- 1. Insert the aliases into instrument_alias
WITH rows AS (
    SELECT id, unnest(regexp_split_to_array(regexp_replace(description, '.*Other names(?: include)?:? (.*?)\.? *$', E'\\1'), ', +| +and +')) AS name
    FROM instrument
    WHERE description ~ 'Other name'
)
INSERT INTO instrument_alias (instrument, name, sort_name) SELECT id, name, name FROM rows ORDER BY id, name;

-- 2. Remove the aliases from the instrument descriptions
UPDATE instrument
SET description = regexp_replace(description, ' ?Other names(?: include)?:? (.*?)\.? *$', '')
WHERE description ~ '.*Other names(?: include)?:? (.*?)\.? *$';

UPDATE link_attribute_type
SET description = regexp_replace(description, ' ?Other names(?: include)?:? (.*?)\.? *$', '')
WHERE description ~ '.*Other names(?: include)?:? (.*?)\.? *$'
AND root = 14;


-- Turn instrument tree into relationships
INSERT INTO l_instrument_instrument (link, entity0, entity1)
SELECT link.id, i_parent.id, i_child.id
FROM (
    SELECT l.id
    FROM link_type lt
    JOIN link l ON l.link_type = lt.id
    WHERE lt.name = 'child'
    AND lt.entity_type0 = 'instrument'
) AS link,
link_attribute_type a_child
JOIN link_attribute_type a_parent ON a_parent.id = a_child.parent
JOIN instrument i_parent ON i_parent.gid = a_parent.gid
JOIN instrument i_child ON i_child.gid = a_child.gid
WHERE a_child.root = 14
AND a_child.parent != 14
ORDER BY link.id, i_parent.id, i_child.id;


-- Flatten the instrument tree
UPDATE link_attribute_type SET child_order = 0, parent = 14 WHERE root = 14 AND id != 14;


SELECT setval('instrument_type_id_seq', (SELECT MAX(id) FROM instrument_type));
SELECT setval('instrument_id_seq', (SELECT MAX(id) FROM instrument));
SELECT setval('instrument_alias_type_id_seq', (SELECT MAX(id) FROM instrument_alias_type));
SELECT setval('instrument_alias_id_seq', (SELECT MAX(id) FROM instrument_alias));
SELECT setval('l_instrument_instrument_id_seq', (SELECT MAX(id) FROM l_instrument_instrument));
SELECT setval('l_instrument_url_id_seq', (SELECT MAX(id) FROM l_instrument_url));
SELECT setval('link_id_seq', (SELECT MAX(id) FROM link));
SELECT setval('link_type_id_seq', (SELECT MAX(id) FROM link_type));
SELECT setval('url_id_seq', (SELECT MAX(id) FROM url));

ALTER TABLE edit_instrument ADD CONSTRAINT edit_instrument_pkey PRIMARY KEY (edit, instrument);
ALTER TABLE instrument ADD CONSTRAINT instrument_pkey PRIMARY KEY (id);
ALTER TABLE instrument_alias ADD CONSTRAINT instrument_alias_pkey PRIMARY KEY (id);
ALTER TABLE instrument_alias_type ADD CONSTRAINT instrument_alias_type_pkey PRIMARY KEY (id);
ALTER TABLE instrument_annotation ADD CONSTRAINT instrument_annotation_pkey PRIMARY KEY (instrument, annotation);
ALTER TABLE instrument_gid_redirect ADD CONSTRAINT instrument_gid_redirect_pkey PRIMARY KEY (gid);
ALTER TABLE instrument_type ADD CONSTRAINT instrument_type_pkey PRIMARY KEY (id);
ALTER TABLE l_area_instrument ADD CONSTRAINT l_area_instrument_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_instrument ADD CONSTRAINT l_artist_instrument_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_instrument ADD CONSTRAINT l_instrument_instrument_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_label ADD CONSTRAINT l_instrument_label_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_place ADD CONSTRAINT l_instrument_place_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_recording ADD CONSTRAINT l_instrument_recording_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_release ADD CONSTRAINT l_instrument_release_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_release_group ADD CONSTRAINT l_instrument_release_group_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_url ADD CONSTRAINT l_instrument_url_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_work ADD CONSTRAINT l_instrument_work_pkey PRIMARY KEY (id);

CREATE INDEX edit_instrument_idx ON edit_label (label);
CREATE UNIQUE INDEX instrument_idx_gid ON instrument (gid);
CREATE INDEX instrument_idx_name ON instrument (name);

CREATE INDEX instrument_alias_idx_instrument ON instrument_alias (instrument);
CREATE UNIQUE INDEX instrument_alias_idx_primary ON instrument_alias (instrument, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;
CREATE UNIQUE INDEX l_area_instrument_idx_uniq ON l_area_label (entity0, entity1, link);
CREATE UNIQUE INDEX l_artist_instrument_idx_uniq ON l_artist_label (entity0, entity1, link);
CREATE UNIQUE INDEX l_instrument_instrument_idx_uniq ON l_instrument_instrument (entity0, entity1, link);
CREATE UNIQUE INDEX l_instrument_label_idx_uniq ON l_instrument_label (entity0, entity1, link);
CREATE UNIQUE INDEX l_instrument_place_idx_uniq ON l_instrument_place (entity0, entity1, link);
CREATE UNIQUE INDEX l_instrument_recording_idx_uniq ON l_instrument_recording (entity0, entity1, link);
CREATE UNIQUE INDEX l_instrument_release_idx_uniq ON l_instrument_release (entity0, entity1, link);
CREATE UNIQUE INDEX l_instrument_release_group_idx_uniq ON l_instrument_release_group (entity0, entity1, link);
CREATE UNIQUE INDEX l_instrument_url_idx_uniq ON l_instrument_url (entity0, entity1, link);
CREATE UNIQUE INDEX l_instrument_work_idx_uniq ON l_instrument_work (entity0, entity1, link);
CREATE INDEX l_area_instrument_idx_entity1 ON l_area_label (entity1);
CREATE INDEX l_artist_instrument_idx_entity1 ON l_artist_label (entity1);
CREATE INDEX l_instrument_instrument_idx_entity1 ON l_instrument_instrument (entity1);
CREATE INDEX l_instrument_label_idx_entity1 ON l_instrument_label (entity1);
CREATE INDEX l_instrument_place_idx_entity1 ON l_instrument_place (entity1);
CREATE INDEX l_instrument_recording_idx_entity1 ON l_instrument_recording (entity1);
CREATE INDEX l_instrument_release_idx_entity1 ON l_instrument_release (entity1);
CREATE INDEX l_instrument_release_group_idx_entity1 ON l_instrument_release_group (entity1);
CREATE INDEX l_instrument_url_idx_entity1 ON l_instrument_url (entity1);
CREATE INDEX l_instrument_work_idx_entity1 ON l_instrument_work (entity1);

CREATE INDEX instrument_idx_txt ON instrument USING gin(to_tsvector('mb_simple', name));

COMMIT;
