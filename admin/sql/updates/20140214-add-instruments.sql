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
    comment             VARCHAR(255) NOT NULL DEFAULT ''
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
             CONSTRAINT primary_check
                 CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL)));

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
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_artist_instrument
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references instrument.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_instrument_label
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references label.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_instrument_instrument
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references instrument.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_instrument_place
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_instrument_recording
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_instrument_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_instrument_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_instrument_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_instrument_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO instrument_type (name) VALUES ('Wind instrument'), ('String instrument'), ('Percussion instrument'), ('Electronic instrument'), ('Other instrument');

INSERT INTO instrument_alias_type (name) VALUES ('Instrument name'), ('Search hint');

INSERT INTO instrument (gid, name, description) SELECT gid, name, description FROM link_attribute_type WHERE parent IS NOT NULL AND root = 14 ORDER BY id;

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

INSERT INTO link (link_type) SELECT id FROM link_type WHERE entity_type0 = 'instrument';


-- Remove descriptions which are just the same as the name
UPDATE instrument SET description = '' WHERE description = name;


-- Migrate URLs from instrument descriptions to URL relationships

-- 1. Insert the URLs into the url table
WITH urls AS (
	SELECT DISTINCT regexp_replace(description, '.*\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$', E'\\1') as url
	FROM link_attribute_type
	WHERE root = 14
	AND description ~ '.*\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$'
)
INSERT INTO url (gid, url)
SELECT generate_uuid_v4(), url
FROM urls
WHERE url NOT IN (SELECT url FROM url WHERE url = urls.url);


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
WHERE i.description ~ '.*\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$';


-- 3. Remove the URLs from the instrument descriptions
UPDATE instrument
SET description = regexp_replace(description, ' *\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$', '')
WHERE description ~ '.*\(<a href="(https?://[a-z]+.wikipedia.org/wiki/[^#"]+)">Wikipedia</a>\)$';


-- Migrate aliases from instrument descriptions to instrument aliases

-- 1. Insert the aliases into instrument_alias
WITH rows AS (
	SELECT id, unnest(regexp_split_to_array(regexp_replace(description, '.*Other names(?: include)?:? (.*?).? *$', E'\\1'), ', | and ')) AS name
	FROM instrument
	WHERE description ~ 'Other name'
)
INSERT INTO instrument_alias (instrument, name, sort_name) SELECT id, name, name FROM rows;

-- 2. Remove the aliases from the instrument descriptions
UPDATE instrument
SET description = regexp_replace(description, ' ?Other names(?: include)?:? (.*?).? *$', '')
WHERE description ~ '.*Other names(?: include)?:? (.*?).? *$';


COMMIT;
