\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE l_area_genre ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references genre.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_genre ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references genre.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_event_genre ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references genre.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_genre_genre ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references genre.id
    entity1             INTEGER NOT NULL, -- references genre.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_genre_instrument ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references genre.id
    entity1             INTEGER NOT NULL, -- references instrument.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_genre_label ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references genre.id
    entity1             INTEGER NOT NULL, -- references label.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_genre_place ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references genre.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_genre_recording ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references genre.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_genre_release ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references genre.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_genre_release_group ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references genre.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_genre_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references genre.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_genre_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references genre.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_genre_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references genre.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);


ALTER TABLE l_area_genre ADD CONSTRAINT l_area_genre_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_genre ADD CONSTRAINT l_artist_genre_pkey PRIMARY KEY (id);
ALTER TABLE l_event_genre ADD CONSTRAINT l_event_genre_pkey PRIMARY KEY (id);
ALTER TABLE l_genre_genre ADD CONSTRAINT l_genre_genre_pkey PRIMARY KEY (id);
ALTER TABLE l_genre_instrument ADD CONSTRAINT l_genre_instrument_pkey PRIMARY KEY (id);
ALTER TABLE l_genre_label ADD CONSTRAINT l_genre_label_pkey PRIMARY KEY (id);
ALTER TABLE l_genre_place ADD CONSTRAINT l_genre_place_pkey PRIMARY KEY (id);
ALTER TABLE l_genre_recording ADD CONSTRAINT l_genre_recording_pkey PRIMARY KEY (id);
ALTER TABLE l_genre_release ADD CONSTRAINT l_genre_release_pkey PRIMARY KEY (id);
ALTER TABLE l_genre_release_group ADD CONSTRAINT l_genre_release_group_pkey PRIMARY KEY (id);
ALTER TABLE l_genre_series ADD CONSTRAINT l_genre_series_pkey PRIMARY KEY (id);
ALTER TABLE l_genre_url ADD CONSTRAINT l_genre_url_pkey PRIMARY KEY (id);
ALTER TABLE l_genre_work ADD CONSTRAINT l_genre_work_pkey PRIMARY KEY (id);

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


CREATE UNIQUE INDEX l_area_genre_idx_uniq ON l_area_genre (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_genre_idx_uniq ON l_artist_genre (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_genre_idx_uniq ON l_event_genre (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_genre_genre_idx_uniq ON l_genre_genre (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_genre_instrument_idx_uniq ON l_genre_instrument (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_genre_label_idx_uniq ON l_genre_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_genre_place_idx_uniq ON l_genre_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_genre_recording_idx_uniq ON l_genre_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_genre_release_idx_uniq ON l_genre_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_genre_release_group_idx_uniq ON l_genre_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_genre_series_idx_uniq ON l_genre_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_genre_url_idx_uniq ON l_genre_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_genre_work_idx_uniq ON l_genre_work (entity0, entity1, link, link_order);

CREATE INDEX l_area_genre_idx_entity1 ON l_area_genre (entity1);
CREATE INDEX l_artist_genre_idx_entity1 ON l_artist_genre (entity1);
CREATE INDEX l_event_genre_idx_entity1 ON l_event_genre (entity1);
CREATE INDEX l_genre_genre_idx_entity1 ON l_genre_genre (entity1);
CREATE INDEX l_genre_instrument_idx_entity1 ON l_genre_instrument (entity1);
CREATE INDEX l_genre_label_idx_entity1 ON l_genre_label (entity1);
CREATE INDEX l_genre_place_idx_entity1 ON l_genre_place (entity1);
CREATE INDEX l_genre_recording_idx_entity1 ON l_genre_recording (entity1);
CREATE INDEX l_genre_release_idx_entity1 ON l_genre_release (entity1);
CREATE INDEX l_genre_release_group_idx_entity1 ON l_genre_release_group (entity1);
CREATE INDEX l_genre_series_idx_entity1 ON l_genre_series (entity1);
CREATE INDEX l_genre_url_idx_entity1 ON l_genre_url (entity1);
CREATE INDEX l_genre_work_idx_entity1 ON l_genre_work (entity1);


CREATE TABLE documentation.l_area_genre_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_area_genre.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_artist_genre_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_artist_genre.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_event_genre_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_event_genre.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_genre_genre_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_genre.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_genre_instrument_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_instrument.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_genre_label_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_label.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_genre_place_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_place.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_genre_recording_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_recording.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_genre_release_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_release.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_genre_release_group_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_release_group.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_genre_series_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_series.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_genre_url_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_url.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE documentation.l_genre_work_example ( -- replicate (verbose)
  id INTEGER NOT NULL, -- PK, references musicbrainz.l_genre_work.id
  published BOOLEAN NOT NULL,
  name TEXT NOT NULL
);


ALTER TABLE documentation.l_area_genre_example ADD CONSTRAINT l_area_genre_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_artist_genre_example ADD CONSTRAINT l_artist_genre_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_event_genre_example ADD CONSTRAINT l_event_genre_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_genre_genre_example ADD CONSTRAINT l_genre_genre_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_genre_instrument_example ADD CONSTRAINT l_genre_instrument_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_genre_label_example ADD CONSTRAINT l_genre_label_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_genre_place_example ADD CONSTRAINT l_genre_place_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_genre_recording_example ADD CONSTRAINT l_genre_recording_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_genre_release_example ADD CONSTRAINT l_genre_release_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_genre_release_group_example ADD CONSTRAINT l_genre_release_group_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_genre_series_example ADD CONSTRAINT l_genre_series_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_genre_url_example ADD CONSTRAINT l_genre_url_example_pkey PRIMARY KEY (id);
ALTER TABLE documentation.l_genre_work_example ADD CONSTRAINT l_genre_work_example_pkey PRIMARY KEY (id);

COMMIT;
