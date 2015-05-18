\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE recording_alias_type ( -- replicate
    id SERIAL, -- PK,
    name TEXT NOT NULL,
    parent              INTEGER, -- references recording_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT
);

CREATE TABLE recording_alias ( -- replicate (verbose)
    id                  SERIAL, --PK
    recording           INTEGER NOT NULL, -- references recording.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references recording_alias_type.id
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

CREATE TABLE release_alias_type ( -- replicate
    id SERIAL, -- PK,
    name TEXT NOT NULL,
    parent              INTEGER, -- references release_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT
);

CREATE TABLE release_alias ( -- replicate (verbose)
    id                  SERIAL, --PK
    release             INTEGER NOT NULL, -- references release.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references release_alias_type.id
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

CREATE TABLE release_group_alias_type ( -- replicate
    id SERIAL, -- PK,
    name TEXT NOT NULL,
    parent              INTEGER, -- references release_group_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT
);

CREATE TABLE release_group_alias ( -- replicate (verbose)
    id                  SERIAL, --PK
    release_group       INTEGER NOT NULL, -- references release_group.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references release_group_alias_type.id
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


CREATE OR REPLACE FUNCTION unique_primary_recording_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE recording_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND recording = NEW.recording;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION unique_primary_release_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE release_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND release = NEW.release;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION unique_primary_release_group_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE release_group_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND release_group = NEW.release_group;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE INDEX recording_alias_idx_recording ON recording_alias (recording);
CREATE UNIQUE INDEX recording_alias_idx_primary ON recording_alias (recording, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX release_alias_idx_release ON release_alias (release);
CREATE UNIQUE INDEX release_alias_idx_primary ON release_alias (release, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX release_group_alias_idx_release_group ON release_group_alias (release_group);
CREATE UNIQUE INDEX release_group_alias_idx_primary ON release_group_alias (release_group, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;


ALTER TABLE recording_alias ADD CONSTRAINT recording_alias_pkey PRIMARY KEY (id);
ALTER TABLE recording_alias_type ADD CONSTRAINT recording_alias_type_pkey PRIMARY KEY (id);
ALTER TABLE release_alias ADD CONSTRAINT release_alias_pkey PRIMARY KEY (id);
ALTER TABLE release_alias_type ADD CONSTRAINT release_alias_type_pkey PRIMARY KEY (id);
ALTER TABLE release_group_alias ADD CONSTRAINT release_group_alias_pkey PRIMARY KEY (id);
ALTER TABLE release_group_alias_type ADD CONSTRAINT release_group_alias_type_pkey PRIMARY KEY (id);

 
CREATE INDEX release_alias_idx_txt ON release_alias USING gin(to_tsvector('mb_simple', name));
CREATE INDEX release_alias_idx_txt_sort ON release_alias USING gin(to_tsvector('mb_simple', sort_name));

CREATE INDEX release_group_alias_idx_txt ON release_group_alias USING gin(to_tsvector('mb_simple', name));
CREATE INDEX release_group_alias_idx_txt_sort ON release_group_alias USING gin(to_tsvector('mb_simple', sort_name));

CREATE INDEX recording_alias_idx_txt ON recording_alias USING gin(to_tsvector('mb_simple', name));
CREATE INDEX recording_alias_idx_txt_sort ON recording_alias USING gin(to_tsvector('mb_simple', sort_name));

INSERT INTO recording_alias_type (name) VALUES ('Recording name'), ('Search hint');
INSERT INTO release_alias_type (name) VALUES ('Release name'), ('Search hint');
INSERT INTO release_group_alias_type (name) VALUES ('Release group name'), ('Search hint');

SELECT setval('recording_alias_type_id_seq', (SELECT MAX(id) FROM recording_alias_type));
SELECT setval('release_alias_type_id_seq', (SELECT MAX(id) FROM release_alias_type));
SELECT setval('release_group_alias_type_id_seq', (SELECT MAX(id) FROM release_group_alias_type));

COMMIT;
