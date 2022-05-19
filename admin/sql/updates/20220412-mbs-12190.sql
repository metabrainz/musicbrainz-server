\set ON_ERROR_STOP 1

BEGIN;

-- Tables

CREATE TABLE edit_mood
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    mood                INTEGER NOT NULL  -- PK, references mood.id CASCADE
);

CREATE TABLE l_area_mood ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references mood.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_mood ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references mood.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_event_mood ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references mood.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_genre_mood ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references genre.id
    entity1             INTEGER NOT NULL, -- references mood.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_instrument_mood ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references mood.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_label_mood ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references mood.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_mood_mood ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references mood.id
    entity1             INTEGER NOT NULL, -- references mood.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_mood_place ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references mood.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_mood_recording ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references mood.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_mood_release ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references mood.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_mood_release_group ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references mood.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_mood_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references mood.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_mood_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references mood.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_mood_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references mood.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE mood ( -- replicate (verbose)
    id                  SERIAL, -- PK
    gid                 UUID NOT NULL,
    name                VARCHAR NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE mood_alias_type ( -- replicate
    id                  SERIAL, -- PK,
    name                TEXT NOT NULL,
    parent              INTEGER, -- references mood_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE mood_alias ( -- replicate (verbose)
    id                  SERIAL, --PK
    mood                INTEGER NOT NULL, -- references mood.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references mood_alias_type.id
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

CREATE TABLE mood_annotation ( -- replicate (verbose)
    mood        INTEGER NOT NULL, -- PK, references mood.id
    annotation  INTEGER NOT NULL -- PK, references annotation.id
);


-- Indexes

CREATE INDEX edit_mood_idx ON edit_mood (mood);

CREATE UNIQUE INDEX l_area_mood_idx_uniq ON l_area_mood (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_mood_idx_uniq ON l_artist_mood (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_mood_idx_uniq ON l_event_mood (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_genre_mood_idx_uniq ON l_genre_mood (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_mood_idx_uniq ON l_instrument_mood (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_mood_idx_uniq ON l_label_mood (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_mood_mood_idx_uniq ON l_mood_mood (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_mood_place_idx_uniq ON l_mood_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_mood_recording_idx_uniq ON l_mood_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_mood_release_idx_uniq ON l_mood_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_mood_release_group_idx_uniq ON l_mood_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_mood_series_idx_uniq ON l_mood_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_mood_url_idx_uniq ON l_mood_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_mood_work_idx_uniq ON l_mood_work (entity0, entity1, link, link_order);

CREATE INDEX l_area_mood_idx_entity1 ON l_area_mood (entity1);
CREATE INDEX l_artist_mood_idx_entity1 ON l_artist_mood (entity1);
CREATE INDEX l_event_mood_idx_entity1 ON l_event_mood (entity1);
CREATE INDEX l_genre_mood_idx_entity1 ON l_genre_mood (entity1);
CREATE INDEX l_instrument_mood_idx_entity1 ON l_instrument_mood (entity1);
CREATE INDEX l_label_mood_idx_entity1 ON l_label_mood (entity1);
CREATE INDEX l_mood_mood_idx_entity1 ON l_mood_mood (entity1);
CREATE INDEX l_mood_place_idx_entity1 ON l_mood_place (entity1);
CREATE INDEX l_mood_recording_idx_entity1 ON l_mood_recording (entity1);
CREATE INDEX l_mood_release_idx_entity1 ON l_mood_release (entity1);
CREATE INDEX l_mood_release_group_idx_entity1 ON l_mood_release_group (entity1);
CREATE INDEX l_mood_series_idx_entity1 ON l_mood_series (entity1);
CREATE INDEX l_mood_url_idx_entity1 ON l_mood_url (entity1);
CREATE INDEX l_mood_work_idx_entity1 ON l_mood_work (entity1);

CREATE UNIQUE INDEX mood_idx_gid ON mood (gid);
CREATE UNIQUE INDEX mood_idx_name ON mood (LOWER(name));

CREATE INDEX mood_alias_idx_mood ON mood_alias (mood);
CREATE UNIQUE INDEX mood_alias_idx_primary ON mood_alias (mood, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE UNIQUE INDEX mood_alias_type_idx_gid ON mood_alias_type (gid);

-- generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'mood_type' || id);
INSERT INTO mood_alias_type (id, gid, name)
    VALUES (1, '4df5b403-3059-36f8-a96f-cf04313dc007', 'Mood name'),
           (2, 'ccd867f1-81ba-3520-89a5-0b0d7a5f6f74', 'Search hint');


-- PKs

ALTER TABLE edit_mood ADD CONSTRAINT edit_mood_pkey PRIMARY KEY (edit, mood);
ALTER TABLE l_area_mood ADD CONSTRAINT l_area_mood_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_mood ADD CONSTRAINT l_artist_mood_pkey PRIMARY KEY (id);
ALTER TABLE l_event_mood ADD CONSTRAINT l_event_mood_pkey PRIMARY KEY (id);
ALTER TABLE l_genre_mood ADD CONSTRAINT l_genre_mood_pkey PRIMARY KEY (id);
ALTER TABLE l_instrument_mood ADD CONSTRAINT l_instrument_mood_pkey PRIMARY KEY (id);
ALTER TABLE l_label_mood ADD CONSTRAINT l_label_mood_pkey PRIMARY KEY (id);
ALTER TABLE l_mood_mood ADD CONSTRAINT l_mood_mood_pkey PRIMARY KEY (id);
ALTER TABLE l_mood_place ADD CONSTRAINT l_mood_place_pkey PRIMARY KEY (id);
ALTER TABLE l_mood_recording ADD CONSTRAINT l_mood_recording_pkey PRIMARY KEY (id);
ALTER TABLE l_mood_release ADD CONSTRAINT l_mood_release_pkey PRIMARY KEY (id);
ALTER TABLE l_mood_release_group ADD CONSTRAINT l_mood_release_group_pkey PRIMARY KEY (id);
ALTER TABLE l_mood_series ADD CONSTRAINT l_mood_series_pkey PRIMARY KEY (id);
ALTER TABLE l_mood_url ADD CONSTRAINT l_mood_url_pkey PRIMARY KEY (id);
ALTER TABLE l_mood_work ADD CONSTRAINT l_mood_work_pkey PRIMARY KEY (id);
ALTER TABLE mood ADD CONSTRAINT mood_pkey PRIMARY KEY (id);
ALTER TABLE mood_alias ADD CONSTRAINT mood_alias_pkey PRIMARY KEY (id);
ALTER TABLE mood_alias_type ADD CONSTRAINT mood_alias_type_pkey PRIMARY KEY (id);
ALTER TABLE mood_annotation ADD CONSTRAINT mood_annotation_pkey PRIMARY KEY (mood, annotation);


-- Functions

CREATE OR REPLACE FUNCTION delete_unused_url(ids INTEGER[])
RETURNS VOID AS $$
DECLARE
  clear_up INTEGER[];
BEGIN
  SELECT ARRAY(
    SELECT id FROM url url_row WHERE id = any(ids)
    EXCEPT
    SELECT url FROM edit_url JOIN edit ON (edit.id = edit_url.edit) WHERE edit.status = 1
    EXCEPT
    SELECT entity1 FROM l_area_url
    EXCEPT
    SELECT entity1 FROM l_artist_url
    EXCEPT
    SELECT entity1 FROM l_event_url
    EXCEPT
    SELECT entity1 FROM l_genre_url
    EXCEPT
    SELECT entity1 FROM l_instrument_url
    EXCEPT
    SELECT entity1 FROM l_label_url
    EXCEPT
    SELECT entity1 FROM l_mood_url
    EXCEPT
    SELECT entity1 FROM l_place_url
    EXCEPT
    SELECT entity1 FROM l_recording_url
    EXCEPT
    SELECT entity1 FROM l_release_url
    EXCEPT
    SELECT entity1 FROM l_release_group_url
    EXCEPT
    SELECT entity1 FROM l_series_url
    EXCEPT
    SELECT entity1 FROM l_url_url
    EXCEPT
    SELECT entity0 FROM l_url_url
    EXCEPT
    SELECT entity0 FROM l_url_work
  ) INTO clear_up;

  DELETE FROM url_gid_redirect WHERE new_id = any(clear_up);
  DELETE FROM url WHERE id = any(clear_up);
END;
$$ LANGUAGE 'plpgsql';


-- Examples

CREATE TABLE documentation.l_area_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_artist_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_event_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_genre_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_instrument_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_instrument_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_label_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_label_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_mood_mood_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_mood.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_mood_place_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_place.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_mood_recording_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_mood_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_mood_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_mood_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_mood_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_mood_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_mood_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

ALTER TABLE documentation.l_area_mood_example ADD CONSTRAINT l_area_mood_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_artist_mood_example ADD CONSTRAINT l_artist_mood_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_event_mood_example ADD CONSTRAINT l_event_mood_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_genre_mood_example ADD CONSTRAINT l_genre_mood_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_instrument_mood_example ADD CONSTRAINT l_instrument_mood_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_label_mood_example ADD CONSTRAINT l_label_mood_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_mood_mood_example ADD CONSTRAINT l_mood_mood_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_mood_place_example ADD CONSTRAINT l_mood_place_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_mood_recording_example ADD CONSTRAINT l_mood_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_mood_release_example ADD CONSTRAINT l_mood_release_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_mood_release_group_example ADD CONSTRAINT l_mood_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_mood_series_example ADD CONSTRAINT l_mood_series_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_mood_url_example ADD CONSTRAINT l_mood_url_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_mood_work_example ADD CONSTRAINT l_mood_work_example_pkey PRIMARY KEY (id);

COMMIT;
