BEGIN;

-----------------------
-- CREATE NEW TABLES --
-----------------------

CREATE TABLE place (
    id                  SERIAL, -- PK
    gid                 uuid NOT NULL,
    name                VARCHAR NOT NULL,
    type                INTEGER, -- references place_type.id
    address             VARCHAR NOT NULL DEFAULT '',
    area                INTEGER, -- references area.id
    coordinates         POINT,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
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
      )
);
CREATE TABLE place_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references place.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE place_type (
    id                  SERIAL, -- PK
    name                VARCHAR(255) NOT NULL
);


--edit
CREATE TABLE edit_place
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    place               INTEGER NOT NULL  -- PK, references place.id CASCADE
);


-- aliases
CREATE TABLE place_alias
(
    id                  SERIAL,
    place               INTEGER NOT NULL, -- references place.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references place_alias_type.id
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
CREATE TABLE place_alias_type (
    id SERIAL,
    name TEXT NOT NULL
);


-- annotation
CREATE TABLE place_annotation
(
    place               INTEGER NOT NULL, -- PK, references place.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

-- relationships 
CREATE TABLE l_area_place
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_artist_place
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_label_place
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_place_place
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_place_recording
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_place_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_place_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_place_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE l_place_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


-- tags
CREATE TABLE place_tag
(
    place               INTEGER NOT NULL, -- PK, references place.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TABLE place_tag_raw
(
    place               INTEGER NOT NULL, -- PK, references place.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL -- PK, references tag.id
);


-------------------------
-- INSERT INITIAL DATA --
-------------------------

-- basic types
INSERT INTO place_type (id, name) VALUES (1, 'Studio'), (2, 'Venue'), (3, 'Other');

-- alias types
INSERT INTO place_alias_type (id, name) VALUES (1, 'Place name'), (2, 'Search hint');


--------------------
-- CREATE INDEXES --
--------------------

CREATE UNIQUE INDEX place_idx_gid ON place (gid);
CREATE INDEX place_idx_name ON place (name);
CREATE INDEX place_idx_page ON place (page_index(name));
CREATE INDEX place_idx_area ON place (area);

CREATE INDEX edit_place_idx ON edit_place (place);

CREATE UNIQUE INDEX l_area_place_idx_uniq ON l_area_place (entity0, entity1, link);
CREATE UNIQUE INDEX l_artist_place_idx_uniq ON l_artist_place (entity0, entity1, link);
CREATE UNIQUE INDEX l_label_place_idx_uniq ON l_label_place (entity0, entity1, link);
CREATE UNIQUE INDEX l_place_place_idx_uniq ON l_place_place (entity0, entity1, link);
CREATE UNIQUE INDEX l_place_recording_idx_uniq ON l_place_recording (entity0, entity1, link);
CREATE UNIQUE INDEX l_place_release_idx_uniq ON l_place_release (entity0, entity1, link);
CREATE UNIQUE INDEX l_place_release_group_idx_uniq ON l_place_release_group (entity0, entity1, link);
CREATE UNIQUE INDEX l_place_url_idx_uniq ON l_place_url (entity0, entity1, link);
CREATE UNIQUE INDEX l_place_work_idx_uniq ON l_place_work (entity0, entity1, link);

CREATE INDEX l_area_place_idx_entity1 ON l_area_place (entity1);
CREATE INDEX l_artist_place_idx_entity1 ON l_artist_place (entity1);
CREATE INDEX l_label_place_idx_entity1 ON l_label_place (entity1);
CREATE INDEX l_place_place_idx_entity1 ON l_place_place (entity1);
CREATE INDEX l_place_recording_idx_entity1 ON l_place_recording (entity1);
CREATE INDEX l_place_release_idx_entity1 ON l_place_release (entity1);
CREATE INDEX l_place_release_group_idx_entity1 ON l_place_release_group (entity1);
CREATE INDEX l_place_url_idx_entity1 ON l_place_url (entity1);
CREATE INDEX l_place_work_idx_entity1 ON l_place_work (entity1);

CREATE INDEX place_alias_idx_place ON place_alias (place);
CREATE UNIQUE INDEX place_alias_idx_primary ON place_alias (place, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX place_tag_idx_tag ON place_tag (tag);

CREATE INDEX place_tag_raw_idx_tag ON place_tag_raw (tag);
CREATE INDEX place_tag_raw_idx_editor ON place_tag_raw (editor);

COMMIT;
