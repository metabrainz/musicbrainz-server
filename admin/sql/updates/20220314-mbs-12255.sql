\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE genre_alias_type ( -- replicate
    id                  SERIAL, -- PK,
    name                TEXT NOT NULL,
    parent              INTEGER, -- references genre_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

ALTER TABLE genre_alias_type ADD CONSTRAINT genre_alias_type_pkey PRIMARY KEY (id);

CREATE UNIQUE INDEX genre_alias_type_idx_gid ON genre_alias_type (gid);

-- generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'genre_type' || id);
INSERT INTO genre_alias_type (id, gid, name)
    VALUES (1, '61e89fea-acce-3908-a590-d999dc627ac9', 'Genre name'),
           (2, '5d81fc72-598a-3a9d-a85a-a471c6ba84dc', 'Search hint');

-- We drop and recreate the table to standardise it
-- rather than adding a ton of rows to it out of the standard order.
-- This is empty in production and mirrors but might not be on standalone
CREATE TEMPORARY TABLE tmp_genre_alias
    ON COMMIT DROP
    AS
    SELECT * FROM genre_alias;

DROP TABLE genre_alias;

CREATE TABLE genre_alias ( -- replicate (verbose)
    id                  SERIAL, --PK
    genre               INTEGER NOT NULL, -- references genre.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references genre_alias_type.id
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

ALTER TABLE genre_alias ADD CONSTRAINT genre_alias_pkey PRIMARY KEY (id);

CREATE INDEX genre_alias_idx_genre ON genre_alias (genre);
CREATE UNIQUE INDEX genre_alias_idx_primary ON genre_alias (genre, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

INSERT INTO genre_alias (id, genre, name, locale, edits_pending, last_updated, type, sort_name)
SELECT id, genre, name, locale, edits_pending, last_updated, 1, name -- sortname = name, type = genre name
FROM tmp_genre_alias;

COMMIT;
