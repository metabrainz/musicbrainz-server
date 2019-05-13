\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE alternative_release ( -- replicate
    id                      SERIAL, -- PK
    gid                     UUID NOT NULL,
    release                 INTEGER NOT NULL, -- references release.id
    name                    VARCHAR,
    artist_credit           INTEGER, -- references artist_credit.id
    type                    INTEGER NOT NULL, -- references alternative_release_type.id
    language                INTEGER NOT NULL, -- references language.id
    script                  INTEGER NOT NULL, -- references script.id
    comment                 VARCHAR(255) NOT NULL DEFAULT ''
    CHECK (name != '')
);

CREATE TABLE alternative_release_type ( -- replicate
    id                  SERIAL, -- PK
    name                TEXT NOT NULL,
    parent              INTEGER, -- references alternative_release_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 UUID NOT NULL
);

CREATE TABLE alternative_medium ( -- replicate
    id                      SERIAL, -- PK
    medium                  INTEGER NOT NULL, -- FK, references medium.id
    alternative_release     INTEGER NOT NULL, -- references alternative_release.id
    name                    VARCHAR
    CHECK (name != '')
);

CREATE TABLE alternative_track ( -- replicate
    id                      SERIAL, -- PK
    name                    VARCHAR,
    artist_credit           INTEGER, -- references artist_credit.id
    ref_count               INTEGER NOT NULL DEFAULT 0
    CHECK (name != '' AND (name IS NOT NULL OR artist_credit IS NOT NULL))
);

CREATE TABLE alternative_medium_track ( -- replicate
    alternative_medium      INTEGER NOT NULL, -- PK, references alternative_medium.id
    track                   INTEGER NOT NULL, -- PK, references track.id
    alternative_track       INTEGER NOT NULL -- references alternative_track.id
);

CREATE TABLE annotation ( -- replicate (verbose)
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    text                TEXT,
    changelog           VARCHAR(255),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE application
(
    id                  SERIAL,
    owner               INTEGER NOT NULL, -- references editor.id
    name                TEXT NOT NULL,
    oauth_id            TEXT NOT NULL,
    oauth_secret        TEXT NOT NULL,
    oauth_redirect_uri  TEXT
);

CREATE TABLE area_type ( -- replicate
    id                  SERIAL, -- PK
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references area_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE area ( -- replicate (verbose)
    id                  SERIAL, -- PK
    gid                 uuid NOT NULL,
    name                VARCHAR NOT NULL,
    type                INTEGER, -- references area_type.id
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
      ),
    comment             VARCHAR(255) NOT NULL DEFAULT ''
);

CREATE TABLE area_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references area.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE area_alias_type ( -- replicate
    id                  SERIAL, -- PK,
    name                TEXT NOT NULL,
    parent              INTEGER, -- references area_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE area_alias ( -- replicate (verbose)
    id                  SERIAL, --PK
    area                INTEGER NOT NULL, -- references area.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references area_alias_type.id
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

CREATE TABLE area_annotation ( -- replicate (verbose)
    area        INTEGER NOT NULL, -- PK, references area.id
    annotation  INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE area_attribute_type ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL,
    parent              INTEGER, -- references area_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE area_attribute_type_allowed_value ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    area_attribute_type INTEGER NOT NULL, -- references area_attribute_type.id
    value               TEXT,
    parent              INTEGER, -- references area_attribute_type_allowed_value.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE area_attribute ( -- replicate (verbose)
    id                                  SERIAL,  -- PK
    area                                INTEGER NOT NULL, -- references area.id
    area_attribute_type                 INTEGER NOT NULL, -- references area_attribute_type.id
    area_attribute_type_allowed_value   INTEGER, -- references area_attribute_type_allowed_value.id
    area_attribute_text                 TEXT
    CHECK (
        (area_attribute_type_allowed_value IS NULL AND area_attribute_text IS NOT NULL)
        OR
        (area_attribute_type_allowed_value IS NOT NULL AND area_attribute_text IS NULL)
    )
);

CREATE TABLE area_tag ( -- replicate (verbose)
    area                INTEGER NOT NULL, -- PK, references area.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE area_tag_raw (
    area                INTEGER NOT NULL, -- PK, references area.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    is_upvote           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE artist ( -- replicate (verbose)
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                VARCHAR NOT NULL,
    sort_name           VARCHAR NOT NULL,
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    type                INTEGER, -- references artist_type.id
    area                INTEGER, -- references area.id
    gender              INTEGER, -- references gender.id
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended               BOOLEAN NOT NULL DEFAULT FALSE
      CONSTRAINT artist_ended_check CHECK (
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
    begin_area          INTEGER, -- references area.id
    end_area            INTEGER -- references area.id
);

CREATE TABLE artist_alias_type ( -- replicate
    id                  SERIAL,
    name                TEXT NOT NULL,
    parent              INTEGER, -- references artist_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE artist_alias ( -- replicate (verbose)
    id                  SERIAL,
    artist              INTEGER NOT NULL, -- references artist.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references artist_alias_type.id
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
        (type <> 3) OR (
          type = 3 AND sort_name = name AND
          begin_date_year IS NULL AND begin_date_month IS NULL AND begin_date_day IS NULL AND
          end_date_year IS NULL AND end_date_month IS NULL AND end_date_day IS NULL AND
          primary_for_locale IS FALSE AND locale IS NULL
        )
      )
);

CREATE TABLE artist_annotation ( -- replicate (verbose)
    artist              INTEGER NOT NULL, -- PK, references artist.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE artist_attribute_type ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL,
    parent              INTEGER, -- references artist_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE artist_attribute_type_allowed_value ( -- replicate (verbose)
    id                          SERIAL,  -- PK
    artist_attribute_type       INTEGER NOT NULL, -- references artist_attribute_type.id
    value                       TEXT,
    parent                      INTEGER, -- references artist_attribute_type_allowed_value.id
    child_order                 INTEGER NOT NULL DEFAULT 0,
    description                 TEXT,
    gid                         uuid NOT NULL
);

CREATE TABLE artist_attribute ( -- replicate (verbose)
    id                                  SERIAL,  -- PK
    artist                              INTEGER NOT NULL, -- references artist.id
    artist_attribute_type               INTEGER NOT NULL, -- references artist_attribute_type.id
    artist_attribute_type_allowed_value INTEGER, -- references artist_attribute_type_allowed_value.id
    artist_attribute_text               TEXT
    CHECK (
        (artist_attribute_type_allowed_value IS NULL AND artist_attribute_text IS NOT NULL)
        OR
        (artist_attribute_type_allowed_value IS NOT NULL AND artist_attribute_text IS NULL)
    )
);

CREATE TABLE artist_ipi ( -- replicate (verbose)
    artist              INTEGER NOT NULL, -- PK, references artist.id
    ipi                 CHAR(11) NOT NULL CHECK (ipi ~ E'^\\d{11}$'), -- PK
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE artist_isni ( -- replicate (verbose)
    artist              INTEGER NOT NULL, -- PK, references artist.id
    isni                CHAR(16) NOT NULL CHECK (isni ~ E'^\\d{15}[\\dX]$'), -- PK
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE artist_meta ( -- replicate
    id                  INTEGER NOT NULL, -- PK, references artist.id CASCADE
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER
);

CREATE TABLE artist_tag ( -- replicate (verbose)
    artist              INTEGER NOT NULL, -- PK, references artist.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE artist_rating_raw
(
    artist              INTEGER NOT NULL, -- PK, references artist.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

CREATE TABLE artist_tag_raw
(
    artist              INTEGER NOT NULL, -- PK, references artist.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    is_upvote           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE artist_credit ( -- replicate
    id                  SERIAL,
    name                VARCHAR NOT NULL,
    artist_count        SMALLINT NOT NULL,
    ref_count           INTEGER DEFAULT 0,
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0)
);

CREATE TABLE artist_credit_name ( -- replicate (verbose)
    artist_credit       INTEGER NOT NULL, -- PK, references artist_credit.id CASCADE
    position            SMALLINT NOT NULL, -- PK
    artist              INTEGER NOT NULL, -- references artist.id CASCADE
    name                VARCHAR NOT NULL,
    join_phrase         TEXT NOT NULL DEFAULT ''
);

CREATE TABLE artist_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references artist.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE artist_type ( -- replicate
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references artist_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE autoeditor_election
(
    id                  SERIAL,
    candidate           INTEGER NOT NULL, -- references editor.id
    proposer            INTEGER NOT NULL, -- references editor.id
    seconder_1          INTEGER, -- references editor.id
    seconder_2          INTEGER, -- references editor.id
    status              INTEGER NOT NULL DEFAULT 1
                            CHECK (status IN (1,2,3,4,5,6)),
                            -- 1 : has proposer
                            -- 2 : has seconder_1
                            -- 3 : has seconder_2 (voting open)
                            -- 4 : accepted!
                            -- 5 : rejected
                            -- 6 : cancelled (by proposer)
    yes_votes           INTEGER NOT NULL DEFAULT 0,
    no_votes            INTEGER NOT NULL DEFAULT 0,
    propose_time        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    open_time           TIMESTAMP WITH TIME ZONE,
    close_time          TIMESTAMP WITH TIME ZONE
);

CREATE TABLE autoeditor_election_vote
(
    id                  SERIAL,
    autoeditor_election INTEGER NOT NULL, -- references autoeditor_election.id
    voter               INTEGER NOT NULL, -- references editor.id
    vote                INTEGER NOT NULL CHECK (vote IN (-1,0,1)),
    vote_time           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE cdtoc ( -- replicate
    id                  SERIAL,
    discid              CHAR(28) NOT NULL,
    freedb_id           CHAR(8) NOT NULL,
    track_count         INTEGER NOT NULL,
    leadout_offset      INTEGER NOT NULL,
    track_offset        INTEGER[] NOT NULL,
    degraded            BOOLEAN NOT NULL DEFAULT FALSE,
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE cdtoc_raw ( -- replicate
    id                  SERIAL, -- PK
    release             INTEGER NOT NULL, -- references release_raw.id
    discid              CHAR(28) NOT NULL,
    track_count          INTEGER NOT NULL,
    leadout_offset       INTEGER NOT NULL,
    track_offset         INTEGER[] NOT NULL
);

CREATE TABLE country_area ( -- replicate (verbose)
    area                INTEGER -- PK, references area.id
);

CREATE TABLE deleted_entity (
    gid UUID NOT NULL, -- PK
    data JSONB NOT NULL,
    deleted_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE edit
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    type                SMALLINT NOT NULL,
    status              SMALLINT NOT NULL,
    autoedit            SMALLINT NOT NULL DEFAULT 0,
    open_time            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    close_time           TIMESTAMP WITH TIME ZONE,
    expire_time          TIMESTAMP WITH TIME ZONE NOT NULL,
    language            INTEGER, -- references language.id
    quality             SMALLINT NOT NULL DEFAULT 1
);

CREATE TABLE edit_data
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    data                JSONB NOT NULL
);

CREATE TABLE edit_note
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    edit                INTEGER NOT NULL, -- references edit.id
    text                TEXT NOT NULL,
    post_time            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE edit_note_recipient (
    recipient           INTEGER NOT NULL, -- PK, references editor.id
    edit_note           INTEGER NOT NULL  -- PK, references edit_note.id
);

CREATE TABLE edit_area
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    area                INTEGER NOT NULL  -- PK, references area.id CASCADE
);

CREATE TABLE edit_artist
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    artist              INTEGER NOT NULL, -- PK, references artist.id CASCADE
    status              SMALLINT NOT NULL -- materialized from edit.status
);

CREATE TABLE edit_event
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    event               INTEGER NOT NULL  -- PK, references event.id CASCADE
);

CREATE TABLE edit_instrument
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    instrument          INTEGER NOT NULL  -- PK, references instrument.id CASCADE
);

CREATE TABLE edit_label
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    label               INTEGER NOT NULL, -- PK, references label.id CASCADE
    status              SMALLINT NOT NULL -- materialized from edit.status
);

CREATE TABLE edit_place
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    place               INTEGER NOT NULL  -- PK, references place.id CASCADE
);

CREATE TABLE edit_release
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    release             INTEGER NOT NULL  -- PK, references release.id CASCADE
);

CREATE TABLE edit_release_group
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    release_group       INTEGER NOT NULL  -- PK, references release_group.id CASCADE
);

CREATE TABLE edit_recording
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    recording           INTEGER NOT NULL  -- PK, references recording.id CASCADE
);

CREATE TABLE edit_series
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    series              INTEGER NOT NULL  -- PK, references series.id CASCADE
);

CREATE TABLE edit_work
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    work                INTEGER NOT NULL  -- PK, references work.id CASCADE
);

CREATE TABLE edit_url
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    url                 INTEGER NOT NULL  -- PK, references url.id CASCADE
);

CREATE TABLE editor
(
    id                  SERIAL,
    name                VARCHAR(64) NOT NULL,
    privs               INTEGER DEFAULT 0,
    email               VARCHAR(64) DEFAULT NULL,
    website             VARCHAR(255) DEFAULT NULL,
    bio                 TEXT DEFAULT NULL,
    member_since        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    email_confirm_date  TIMESTAMP WITH TIME ZONE,
    last_login_date     TIMESTAMP WITH TIME ZONE DEFAULT now(),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    birth_date          DATE,
    gender              INTEGER, -- references gender.id
    area                INTEGER, -- references area.id
    password            VARCHAR(128) NOT NULL,
    ha1                 CHAR(32) NOT NULL,
    deleted             BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE old_editor_name (
    name    VARCHAR(64) NOT NULL
);

CREATE TYPE FLUENCY AS ENUM ('basic', 'intermediate', 'advanced', 'native');

CREATE TABLE editor_language (
    editor   INTEGER NOT NULL,  -- PK, references editor.id
    language INTEGER NOT NULL,  -- PK, references language.id
    fluency  FLUENCY NOT NULL
);

CREATE TABLE editor_preference
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    name                VARCHAR(50) NOT NULL,
    value               VARCHAR(100) NOT NULL
);

CREATE TABLE editor_subscribe_artist
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    artist              INTEGER NOT NULL, -- references artist.id
    last_edit_sent      INTEGER NOT NULL -- references edit.id
);

CREATE TABLE editor_subscribe_artist_deleted
(
    editor INTEGER NOT NULL, -- PK, references editor.id
    gid UUID NOT NULL, -- PK, references deleted_entity.gid
    deleted_by INTEGER NOT NULL -- references edit.id
);

CREATE TABLE editor_subscribe_collection
(
    id                  SERIAL,
    editor              INTEGER NOT NULL,              -- references editor.id
    collection          INTEGER NOT NULL,              -- weakly references editor_collection.id
    last_edit_sent      INTEGER NOT NULL,              -- weakly references edit.id
    available           BOOLEAN NOT NULL DEFAULT TRUE,
    last_seen_name      VARCHAR(255)
);

CREATE TABLE editor_subscribe_label
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    label               INTEGER NOT NULL, -- references label.id
    last_edit_sent      INTEGER NOT NULL -- references edit.id
);

CREATE TABLE editor_subscribe_label_deleted
(
    editor INTEGER NOT NULL, -- PK, references editor.id
    gid UUID NOT NULL, -- PK, references deleted_entity.gid
    deleted_by INTEGER NOT NULL -- references edit.id
);

CREATE TABLE editor_subscribe_editor
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id (the one who has subscribed)
    subscribed_editor   INTEGER NOT NULL, -- references editor.id (the one being subscribed)
    last_edit_sent      INTEGER NOT NULL  -- weakly references edit.id
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
    gid                 UUID NOT NULL, -- PK, references deleted_entity.gid
    deleted_by          INTEGER NOT NULL -- references edit.id
);

CREATE TABLE event ( -- replicate (verbose)
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                VARCHAR NOT NULL,
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    time                TIME WITHOUT TIME ZONE,
    type                INTEGER, -- references event_type.id
    cancelled           BOOLEAN NOT NULL DEFAULT FALSE,
    setlist             TEXT,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended               BOOLEAN NOT NULL DEFAULT FALSE
      CONSTRAINT event_ended_check CHECK (
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

CREATE TYPE event_art_presence AS ENUM ('absent', 'present', 'darkened');

CREATE TABLE event_meta ( -- replicate
    id                  INTEGER NOT NULL, -- PK, references event.id CASCADE
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER,
    event_art_presence  event_art_presence NOT NULL DEFAULT 'absent'
);

CREATE TABLE event_rating_raw (
    event               INTEGER NOT NULL, -- PK, references event.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

CREATE TABLE event_tag_raw (
    event               INTEGER NOT NULL, -- PK, references event.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    is_upvote           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE event_alias_type ( -- replicate
    id                  SERIAL,
    name                TEXT NOT NULL,
    parent              INTEGER, -- references event_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE event_alias ( -- replicate (verbose)
    id                  SERIAL,
    event               INTEGER NOT NULL, -- references event.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references event_alias_type.id
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

CREATE TABLE event_annotation ( -- replicate (verbose)
    event               INTEGER NOT NULL, -- PK, references event.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE event_attribute_type ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL,
    parent              INTEGER, -- references event_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE event_attribute_type_allowed_value ( -- replicate (verbose)
    id                          SERIAL,  -- PK
    event_attribute_type        INTEGER NOT NULL, -- references event_attribute_type.id
    value                       TEXT,
    parent                      INTEGER, -- references event_attribute_type_allowed_value.id
    child_order                 INTEGER NOT NULL DEFAULT 0,
    description                 TEXT,
    gid                         uuid NOT NULL
);

CREATE TABLE event_attribute ( -- replicate (verbose)
    id                                  SERIAL,  -- PK
    event                               INTEGER NOT NULL, -- references event.id
    event_attribute_type                INTEGER NOT NULL, -- references event_attribute_type.id
    event_attribute_type_allowed_value  INTEGER, -- references event_attribute_type_allowed_value.id
    event_attribute_text                TEXT
    CHECK (
        (event_attribute_type_allowed_value IS NULL AND event_attribute_text IS NOT NULL)
        OR
        (event_attribute_type_allowed_value IS NOT NULL AND event_attribute_text IS NULL)
    )
);

CREATE TABLE event_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references event.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE event_tag ( -- replicate (verbose)
    event               INTEGER NOT NULL, -- PK, references event.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE event_type ( -- replicate
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references event_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE gender ( -- replicate
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references gender.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE genre ( -- replicate (verbose)
    id                  SERIAL, -- PK
    gid                 UUID NOT NULL,
    name                VARCHAR NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE genre_alias ( -- replicate (verbose)
    id                  SERIAL,
    genre               INTEGER NOT NULL, -- references genre.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    primary_for_locale  BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT primary_check CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL))
);

CREATE TABLE instrument_type ( -- replicate
    id                  SERIAL, -- PK
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references instrument_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE instrument ( -- replicate (verbose)
    id                  SERIAL, -- PK
    gid                 uuid NOT NULL,
    name                VARCHAR NOT NULL,
    type                INTEGER, -- references instrument_type.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >=0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    description         TEXT NOT NULL DEFAULT ''
);

CREATE TABLE instrument_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references instrument.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE instrument_alias_type ( -- replicate
    id                  SERIAL, -- PK,
    name                TEXT NOT NULL,
    parent              INTEGER, -- references instrument_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE instrument_alias ( -- replicate (verbose)
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

CREATE TABLE instrument_annotation ( -- replicate (verbose)
    instrument  INTEGER NOT NULL, -- PK, references instrument.id
    annotation  INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE instrument_attribute_type ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL,
    parent              INTEGER, -- references instrument_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE instrument_attribute_type_allowed_value ( -- replicate (verbose)
    id                          SERIAL,  -- PK
    instrument_attribute_type   INTEGER NOT NULL, -- references instrument_attribute_type.id
    value                       TEXT,
    parent                      INTEGER, -- references instrument_attribute_type_allowed_value.id
    child_order                 INTEGER NOT NULL DEFAULT 0,
    description                 TEXT,
    gid                         uuid NOT NULL
);

CREATE TABLE instrument_attribute ( -- replicate (verbose)
    id                                          SERIAL,  -- PK
    instrument                                  INTEGER NOT NULL, -- references instrument.id
    instrument_attribute_type                   INTEGER NOT NULL, -- references instrument_attribute_type.id
    instrument_attribute_type_allowed_value     INTEGER, -- references instrument_attribute_type_allowed_value.id
    instrument_attribute_text                   TEXT
    CHECK (
        (instrument_attribute_type_allowed_value IS NULL AND instrument_attribute_text IS NOT NULL)
        OR
        (instrument_attribute_type_allowed_value IS NOT NULL AND instrument_attribute_text IS NULL)
    )
);

CREATE TABLE instrument_tag ( -- replicate (verbose)
    instrument          INTEGER NOT NULL, -- PK, references instrument.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE instrument_tag_raw (
    instrument          INTEGER NOT NULL, -- PK, references instrument.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    is_upvote           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE iso_3166_1 ( -- replicate
    area      INTEGER NOT NULL, -- references area.id
    code      CHAR(2) -- PK
);
CREATE TABLE iso_3166_2 ( -- replicate
    area      INTEGER NOT NULL, -- references area.id
    code      VARCHAR(10) -- PK
);
CREATE TABLE iso_3166_3 ( -- replicate
    area      INTEGER NOT NULL, -- references area.id
    code      CHAR(4) -- PK
);

CREATE TABLE isrc ( -- replicate (verbose)
    id                  SERIAL,
    recording           INTEGER NOT NULL, -- references recording.id
    isrc                CHAR(12) NOT NULL CHECK (isrc ~ E'^[A-Z]{2}[A-Z0-9]{3}[0-9]{7}$'),
    source              SMALLINT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE iswc ( -- replicate (verbose)
    id SERIAL NOT NULL,
    work INTEGER NOT NULL, -- references work.id
    iswc CHARACTER(15) CHECK (iswc ~ E'^T-?\\d{3}.?\\d{3}.?\\d{3}[-.]?\\d$'),
    source SMALLINT,
    edits_pending INTEGER NOT NULL DEFAULT 0,
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE l_area_area ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references area.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_area_artist ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references artist.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_area_event ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references event.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_area_instrument ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references instrument.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_area_label ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references label.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_area_place ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_area_recording ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_area_release ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_area_release_group ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_area_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_area_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_area_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_artist ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references artist.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_event ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references event.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_instrument ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references instrument.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_label ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references label.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_place ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_recording ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_release ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_release_group ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_artist_work ( -- replicate (verbose)
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_event_event ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references event.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_event_instrument ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references instrument.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_event_label ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references label.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_event_place ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_event_recording ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_event_release ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_event_release_group ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_event_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_event_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_event_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references event.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_label_label ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references label.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_instrument_instrument ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references instrument.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_instrument_label ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references label.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_instrument_place ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_instrument_recording ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_instrument_release ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_instrument_release_group ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_instrument_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_instrument_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_instrument_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references instrument.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_label_place ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_label_recording ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_label_release ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_label_release_group ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_label_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_label_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_label_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_place_place ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references place.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_place_recording ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_place_release ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_place_release_group ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_place_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_place_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_place_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references place.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_recording_recording ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_recording_release ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_recording_release_group ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_recording_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_recording_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_recording_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_release_release ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_release_release_group ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_release_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_release_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_release_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_release_group_release_group ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release_group.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_release_group_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release_group.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_release_group_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release_group.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_release_group_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release_group.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_series_series ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references series.id
    entity1             INTEGER NOT NULL, -- references series.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_series_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references series.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_series_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references series.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_url_url ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references url.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_url_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references url.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE l_work_work ( -- replicate
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references work.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    link_order          INTEGER NOT NULL DEFAULT 0 CHECK (link_order >= 0),
    entity0_credit      TEXT NOT NULL DEFAULT '',
    entity1_credit      TEXT NOT NULL DEFAULT ''
);

CREATE TABLE label ( -- replicate (verbose)
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                VARCHAR NOT NULL,
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    label_code          INTEGER CHECK (label_code > 0 AND label_code < 100000),
    type                INTEGER, -- references label_type.id
    area                INTEGER, -- references area.id
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended               BOOLEAN NOT NULL DEFAULT FALSE
      CONSTRAINT label_ended_check CHECK (
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

CREATE TABLE label_rating_raw
(
    label               INTEGER NOT NULL, -- PK, references label.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

CREATE TABLE label_tag_raw
(
    label               INTEGER NOT NULL, -- PK, references label.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    is_upvote           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE label_alias_type ( -- replicate
    id                  SERIAL,
    name                TEXT NOT NULL,
    parent              INTEGER, -- references label_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE label_alias ( -- replicate (verbose)
    id                  SERIAL,
    label               INTEGER NOT NULL, -- references label.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references label_alias_type.id
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

CREATE TABLE label_annotation ( -- replicate (verbose)
    label               INTEGER NOT NULL, -- PK, references label.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE label_attribute_type ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL,
    parent              INTEGER, -- references label_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE label_attribute_type_allowed_value ( -- replicate (verbose)
    id                          SERIAL,  -- PK
    label_attribute_type        INTEGER NOT NULL, -- references label_attribute_type.id
    value                       TEXT,
    parent                      INTEGER, -- references label_attribute_type_allowed_value.id
    child_order                 INTEGER NOT NULL DEFAULT 0,
    description                 TEXT,
    gid                         uuid NOT NULL
);

CREATE TABLE label_attribute ( -- replicate (verbose)
    id                                  SERIAL,  -- PK
    label                               INTEGER NOT NULL, -- references label.id
    label_attribute_type                INTEGER NOT NULL, -- references label_attribute_type.id
    label_attribute_type_allowed_value  INTEGER, -- references label_attribute_type_allowed_value.id
    label_attribute_text                TEXT
    CHECK (
        (label_attribute_type_allowed_value IS NULL AND label_attribute_text IS NOT NULL)
        OR
        (label_attribute_type_allowed_value IS NOT NULL AND label_attribute_text IS NULL)
    )
);

CREATE TABLE label_ipi ( -- replicate (verbose)
    label               INTEGER NOT NULL, -- PK, references label.id
    ipi                 CHAR(11) NOT NULL CHECK (ipi ~ E'^\\d{11}$'), -- PK
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE label_isni ( -- replicate (verbose)
    label               INTEGER NOT NULL, -- PK, references label.id
    isni                CHAR(16) NOT NULL CHECK (isni ~ E'^\\d{15}[\\dX]$'), -- PK
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE label_meta ( -- replicate
    id                  INTEGER NOT NULL, -- PK, references label.id CASCADE
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER
);

CREATE TABLE label_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references label.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE label_tag ( -- replicate (verbose)
    label               INTEGER NOT NULL, -- PK, references label.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE label_type ( -- replicate
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references label_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE language ( -- replicate
    id                  SERIAL,
    iso_code_2t         CHAR(3), -- ISO 639-2 (T)
    iso_code_2b         CHAR(3), -- ISO 639-2 (B)
    iso_code_1          CHAR(2), -- ISO 639
    name                VARCHAR(100) NOT NULL,
    frequency           INTEGER NOT NULL DEFAULT 0,
    iso_code_3          CHAR(3)  -- ISO 639-3
);

ALTER TABLE language
      ADD CONSTRAINT iso_code_check
      CHECK (iso_code_2t IS NOT NULL OR iso_code_3  IS NOT NULL);

CREATE TABLE link ( -- replicate
    id                  SERIAL,
    link_type           INTEGER NOT NULL, -- references link_type.id
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    attribute_count     INTEGER NOT NULL DEFAULT 0,
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended               BOOLEAN NOT NULL DEFAULT FALSE
      CONSTRAINT link_ended_check CHECK (
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

CREATE TABLE link_attribute ( -- replicate
    link                INTEGER NOT NULL, -- PK, references link.id
    attribute_type      INTEGER NOT NULL, -- PK, references link_attribute_type.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE link_attribute_type ( -- replicate
    id                  SERIAL,
    parent              INTEGER, -- references link_attribute_type.id
    root                INTEGER NOT NULL, -- references link_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    gid                 UUID NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE link_creditable_attribute_type ( -- replicate
  attribute_type INT NOT NULL -- PK, references link_attribute_type.id CASCADE
);

CREATE TABLE link_attribute_credit ( -- replicate
  link INT NOT NULL, -- PK, references link.id
  attribute_type INT NOT NULL, -- PK, references link_creditable_attribute_type.attribute_type
  credited_as TEXT NOT NULL
);

CREATE TABLE link_text_attribute_type ( -- replicate
    attribute_type      INT NOT NULL -- PK, references link_attribute_type.id CASCADE
);

CREATE TABLE link_attribute_text_value ( -- replicate
    link                INT NOT NULL, -- PK, references link.id
    attribute_type      INT NOT NULL, -- PK, references link_text_attribute_type.attribute_type
    text_value          TEXT NOT NULL
);

CREATE TABLE link_type ( -- replicate
    id                  SERIAL,
    parent              INTEGER, -- references link_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    gid                 UUID NOT NULL,
    entity_type0        VARCHAR(50) NOT NULL,
    entity_type1        VARCHAR(50) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    link_phrase         VARCHAR(255) NOT NULL,
    reverse_link_phrase VARCHAR(255) NOT NULL,
    long_link_phrase    VARCHAR(255) NOT NULL,
    priority            INTEGER NOT NULL DEFAULT 0,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_deprecated       BOOLEAN NOT NULL DEFAULT false,
    has_dates           BOOLEAN NOT NULL DEFAULT true,
    entity0_cardinality INTEGER NOT NULL DEFAULT 0,
    entity1_cardinality INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE link_type_attribute_type ( -- replicate
    link_type           INTEGER NOT NULL, -- PK, references link_type.id
    attribute_type      INTEGER NOT NULL, -- PK, references link_attribute_type.id
    min                 SMALLINT,
    max                 SMALLINT,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE editor_collection
(
    id                  SERIAL,
    gid                 UUID NOT NULL,
    editor              INTEGER NOT NULL, -- references editor.id
    name                VARCHAR NOT NULL,
    public              BOOLEAN NOT NULL DEFAULT FALSE,
    description         TEXT DEFAULT '' NOT NULL,
    type                INTEGER NOT NULL -- references editor_collection_type.id
);

CREATE TABLE editor_collection_type ( -- replicate
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    entity_type         VARCHAR(50) NOT NULL,
    parent              INTEGER, -- references editor_collection_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE editor_collection_collaborator (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    editor INTEGER NOT NULL -- PK, references editor.id
);

CREATE TABLE editor_collection_area (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    area INTEGER NOT NULL, -- PK, references area.id
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_collection_artist (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    artist INTEGER NOT NULL, -- PK, references artist.id
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_collection_event (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    event INTEGER NOT NULL, -- PK, references event.id
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_collection_instrument (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    instrument INTEGER NOT NULL, -- PK, references instrument.id
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_collection_label (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    label INTEGER NOT NULL, -- PK, references label.id
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_collection_place (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    place INTEGER NOT NULL, -- PK, references place.id
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_collection_recording (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    recording INTEGER NOT NULL, -- PK, references recording.id
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_collection_release (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    release INTEGER NOT NULL, -- PK, references release.id
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_collection_release_group (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    release_group INTEGER NOT NULL, -- PK, references release_group.id
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_collection_series (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    series INTEGER NOT NULL, -- PK, references series.id
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_collection_work (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    work INTEGER NOT NULL, -- PK, references work.id
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_collection_deleted_entity (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    gid UUID NOT NULL, -- PK, references deleted_entity.gid
    added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    position INTEGER NOT NULL DEFAULT 0 CHECK (position >= 0),
    comment TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_oauth_token
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    application         INTEGER NOT NULL, -- references application.id
    authorization_code  TEXT,
    refresh_token       TEXT,
    access_token        TEXT,
    expire_time         TIMESTAMP WITH TIME ZONE NOT NULL,
    scope               INTEGER NOT NULL DEFAULT 0,
    granted             TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE editor_watch_preferences
(
    editor INTEGER NOT NULL, -- PK, references editor.id CASCADE
    notify_via_email BOOLEAN NOT NULL DEFAULT TRUE,
    notification_timeframe INTERVAL NOT NULL DEFAULT '1 week',
    last_checked TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE editor_watch_artist
(
    artist INTEGER NOT NULL, -- PK, references artist.id CASCADE
    editor INTEGER NOT NULL  -- PK, references editor.id CASCADE
);

CREATE TABLE editor_watch_release_group_type
(
    editor INTEGER NOT NULL, -- PK, references editor.id CASCADE
    release_group_type INTEGER NOT NULL -- PK, references release_group_primary_type.id
);

CREATE TABLE editor_watch_release_status
(
    editor INTEGER NOT NULL, -- PK, references editor.id CASCADE
    release_status INTEGER NOT NULL -- PK, references release_status.id
);

CREATE TABLE medium ( -- replicate (verbose)
    id                  SERIAL,
    release             INTEGER NOT NULL, -- references release.id
    position            INTEGER NOT NULL,
    format              INTEGER, -- references medium_format.id
    name                VARCHAR NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    track_count         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE medium_attribute_type ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL,
    parent              INTEGER, -- references medium_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE medium_attribute_type_allowed_format ( -- replicate (verbose)
    medium_format INTEGER NOT NULL, -- PK, references medium_format.id,
    medium_attribute_type INTEGER NOT NULL -- PK, references medium_attribute_type.id
);

CREATE TABLE medium_attribute_type_allowed_value ( -- replicate (verbose)
    id                          SERIAL,  -- PK
    medium_attribute_type       INTEGER NOT NULL, -- references medium_attribute_type.id
    value                       TEXT,
    parent                      INTEGER, -- references medium_attribute_type_allowed_value.id
    child_order                 INTEGER NOT NULL DEFAULT 0,
    description                 TEXT,
    gid                         uuid NOT NULL
);

CREATE TABLE medium_attribute_type_allowed_value_allowed_format ( -- replicate (verbose)
    medium_format INTEGER NOT NULL, -- PK, references medium_format.id,
    medium_attribute_type_allowed_value INTEGER NOT NULL -- PK, references medium_attribute_type_allowed_value.id
);

CREATE TABLE medium_attribute ( -- replicate (verbose)
    id                                  SERIAL,  -- PK
    medium                              INTEGER NOT NULL, -- references medium.id
    medium_attribute_type               INTEGER NOT NULL, -- references medium_attribute_type.id
    medium_attribute_type_allowed_value INTEGER, -- references medium_attribute_type_allowed_value.id
    medium_attribute_text               TEXT
    CHECK (
        (medium_attribute_type_allowed_value IS NULL AND medium_attribute_text IS NOT NULL)
        OR
        (medium_attribute_type_allowed_value IS NOT NULL AND medium_attribute_text IS NULL)
    )
);

CREATE TABLE medium_cdtoc ( -- replicate (verbose)
    id                  SERIAL,
    medium              INTEGER NOT NULL, -- references medium.id
    cdtoc               INTEGER NOT NULL, -- references cdtoc.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE medium_format ( -- replicate
    id                  SERIAL,
    name                VARCHAR(100) NOT NULL,
    parent              INTEGER, -- references medium_format.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    year                SMALLINT,
    has_discids         BOOLEAN NOT NULL DEFAULT FALSE,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE orderable_link_type ( -- replicate
    link_type           INTEGER NOT NULL, -- PK, references link_type.id
    direction           SMALLINT NOT NULL DEFAULT 1 CHECK (direction = 1 OR direction = 2)
);

CREATE TABLE place ( -- replicate (verbose)
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

CREATE TABLE place_alias ( -- replicate (verbose)
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

CREATE TABLE place_alias_type ( -- replicate
    id                  SERIAL,
    name                TEXT NOT NULL,
    parent              INTEGER, -- references place_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE place_annotation ( -- replicate (verbose)
    place               INTEGER NOT NULL, -- PK, references place.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE place_attribute_type ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL,
    parent              INTEGER, -- references place_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE place_attribute_type_allowed_value ( -- replicate (verbose)
    id                          SERIAL,  -- PK
    place_attribute_type        INTEGER NOT NULL, -- references place_attribute_type.id
    value                       TEXT,
    parent                      INTEGER, -- references place_attribute_type_allowed_value.id
    child_order                 INTEGER NOT NULL DEFAULT 0,
    description                 TEXT,
    gid                         uuid NOT NULL
);

CREATE TABLE place_attribute ( -- replicate (verbose)
    id                                  SERIAL,  -- PK
    place                               INTEGER NOT NULL, -- references place.id
    place_attribute_type                INTEGER NOT NULL, -- references place_attribute_type.id
    place_attribute_type_allowed_value  INTEGER, -- references place_attribute_type_allowed_value.id
    place_attribute_text                TEXT
    CHECK (
        (place_attribute_type_allowed_value IS NULL AND place_attribute_text IS NOT NULL)
        OR
        (place_attribute_type_allowed_value IS NOT NULL AND place_attribute_text IS NULL)
    )
);

CREATE TABLE place_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references place.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE place_tag ( -- replicate (verbose)
    place               INTEGER NOT NULL, -- PK, references place.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE place_tag_raw
(
    place               INTEGER NOT NULL, -- PK, references place.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    is_upvote           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE place_type ( -- replicate
    id                  SERIAL, -- PK
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references place_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE replication_control ( -- replicate
    id                              SERIAL,
    current_schema_sequence         INTEGER NOT NULL,
    current_replication_sequence    INTEGER,
    last_replication_date           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE recording ( -- replicate (verbose)
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                VARCHAR NOT NULL,
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    length              INTEGER CHECK (length IS NULL OR length > 0),
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    video               BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE recording_alias_type ( -- replicate
    id                  SERIAL, -- PK,
    name                TEXT NOT NULL,
    parent              INTEGER, -- references recording_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
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

CREATE TABLE recording_rating_raw
(
    recording           INTEGER NOT NULL, -- PK, references recording.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

CREATE TABLE recording_tag_raw
(
    recording           INTEGER NOT NULL, -- PK, references recording.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    is_upvote           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE recording_annotation ( -- replicate (verbose)
    recording           INTEGER NOT NULL, -- PK, references recording.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE recording_attribute_type ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL,
    parent              INTEGER, -- references recording_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE recording_attribute_type_allowed_value ( -- replicate (verbose)
    id                          SERIAL,  -- PK
    recording_attribute_type    INTEGER NOT NULL, -- references recording_attribute_type.id
    value                       TEXT,
    parent                      INTEGER, -- references recording_attribute_type_allowed_value.id
    child_order                 INTEGER NOT NULL DEFAULT 0,
    description                 TEXT,
    gid                         uuid NOT NULL
);

CREATE TABLE recording_attribute ( -- replicate (verbose)
    id                                          SERIAL,  -- PK
    recording                                   INTEGER NOT NULL, -- references recording.id
    recording_attribute_type                    INTEGER NOT NULL, -- references recording_attribute_type.id
    recording_attribute_type_allowed_value      INTEGER, -- references recording_attribute_type_allowed_value.id
    recording_attribute_text                    TEXT
    CHECK (
        (recording_attribute_type_allowed_value IS NULL AND recording_attribute_text IS NOT NULL)
        OR
        (recording_attribute_type_allowed_value IS NOT NULL AND recording_attribute_text IS NULL)
    )
);

CREATE TABLE recording_meta ( -- replicate
    id                  INTEGER NOT NULL, -- PK, references recording.id CASCADE
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER
);

CREATE TABLE recording_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references recording.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE recording_tag ( -- replicate (verbose)
    recording           INTEGER NOT NULL, -- PK, references recording.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release ( -- replicate (verbose)
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                VARCHAR NOT NULL,
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    release_group       INTEGER NOT NULL, -- references release_group.id
    status              INTEGER, -- references release_status.id
    packaging           INTEGER, -- references release_packaging.id
    language            INTEGER, -- references language.id
    script              INTEGER, -- references script.id
    barcode             VARCHAR(255),
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    quality             SMALLINT NOT NULL DEFAULT -1,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release_alias_type ( -- replicate
    id                  SERIAL, -- PK,
    name                TEXT NOT NULL,
    parent              INTEGER, -- references release_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
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

CREATE TABLE release_country ( -- replicate (verbose)
  release INTEGER NOT NULL,  -- PK, references release.id
  country INTEGER NOT NULL,  -- PK, references country_area.area
  date_year SMALLINT,
  date_month SMALLINT,
  date_day SMALLINT
);

CREATE TABLE release_unknown_country ( -- replicate (verbose)
  release INTEGER NOT NULL,  -- PK, references release.id
  date_year SMALLINT,
  date_month SMALLINT,
  date_day SMALLINT
);

CREATE TABLE release_raw ( -- replicate
    id                  SERIAL, -- PK
    title               VARCHAR(255) NOT NULL,
    artist              VARCHAR(255),
    added               TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_modified        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    lookup_count         INTEGER DEFAULT 0,
    modify_count         INTEGER DEFAULT 0,
    source              INTEGER DEFAULT 0,
    barcode             VARCHAR(255),
    comment             VARCHAR(255) NOT NULL DEFAULT ''
);

CREATE TABLE release_tag_raw
(
    release             INTEGER NOT NULL, -- PK, references release.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    is_upvote           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE release_annotation ( -- replicate (verbose)
    release             INTEGER NOT NULL, -- PK, references release.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE release_attribute_type ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL,
    parent              INTEGER, -- references release_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE release_attribute_type_allowed_value ( -- replicate (verbose)
    id                          SERIAL,  -- PK
    release_attribute_type      INTEGER NOT NULL, -- references release_attribute_type.id
    value                       TEXT,
    parent                      INTEGER, -- references release_attribute_type_allowed_value.id
    child_order                 INTEGER NOT NULL DEFAULT 0,
    description                 TEXT,
    gid                         uuid NOT NULL
);

CREATE TABLE release_attribute ( -- replicate (verbose)
    id                                          SERIAL,  -- PK
    release                                     INTEGER NOT NULL, -- references release.id
    release_attribute_type                      INTEGER NOT NULL, -- references release_attribute_type.id
    release_attribute_type_allowed_value        INTEGER, -- references release_attribute_type_allowed_value.id
    release_attribute_text                      TEXT
    CHECK (
        (release_attribute_type_allowed_value IS NULL AND release_attribute_text IS NOT NULL)
        OR
        (release_attribute_type_allowed_value IS NOT NULL AND release_attribute_text IS NULL)
    )
);

CREATE TABLE release_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references release.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TYPE cover_art_presence AS ENUM ('absent', 'present', 'darkened');

CREATE TABLE release_meta ( -- replicate (verbose)
    id                  INTEGER NOT NULL, -- PK, references release.id CASCADE
    date_added          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    info_url            VARCHAR(255),
    amazon_asin         VARCHAR(10),
    amazon_store        VARCHAR(20),
    cover_art_presence  cover_art_presence NOT NULL DEFAULT 'absent'
);

CREATE TABLE release_coverart
(
    id                  INTEGER NOT NULL, -- PK, references release.id CASCADE
    last_updated        TIMESTAMP WITH TIME ZONE,
    cover_art_url       VARCHAR(255)
);

CREATE TABLE release_label ( -- replicate (verbose)
    id                  SERIAL,
    release             INTEGER NOT NULL, -- references release.id
    label               INTEGER, -- references label.id
    catalog_number      VARCHAR(255),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release_packaging ( -- replicate
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references release_packaging.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE release_status ( -- replicate
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references release_status.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE release_tag ( -- replicate (verbose)
    release             INTEGER NOT NULL, -- PK, references release.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release_group ( -- replicate (verbose)
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                VARCHAR NOT NULL,
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    type                INTEGER, -- references release_group_primary_type.id
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release_group_alias_type ( -- replicate
    id                  SERIAL, -- PK,
    name                TEXT NOT NULL,
    parent              INTEGER, -- references release_group_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
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

CREATE TABLE release_group_rating_raw
(
    release_group       INTEGER NOT NULL, -- PK, references release_group.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

CREATE TABLE release_group_tag_raw
(
    release_group       INTEGER NOT NULL, -- PK, references release_group.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    is_upvote           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE release_group_annotation ( -- replicate (verbose)
    release_group       INTEGER NOT NULL, -- PK, references release_group.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE release_group_attribute_type ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL,
    parent              INTEGER, -- references release_group_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE release_group_attribute_type_allowed_value ( -- replicate (verbose)
    id                                  SERIAL,  -- PK
    release_group_attribute_type        INTEGER NOT NULL, -- references release_group_attribute_type.id
    value                               TEXT,
    parent                              INTEGER, -- references release_group_attribute_type_allowed_value.id
    child_order                         INTEGER NOT NULL DEFAULT 0,
    description                         TEXT,
    gid                                 uuid NOT NULL
);

CREATE TABLE release_group_attribute ( -- replicate (verbose)
    id                                          SERIAL,  -- PK
    release_group                               INTEGER NOT NULL, -- references release_group.id
    release_group_attribute_type                INTEGER NOT NULL, -- references release_group_attribute_type.id
    release_group_attribute_type_allowed_value  INTEGER, -- references release_group_attribute_type_allowed_value.id
    release_group_attribute_text                TEXT
    CHECK (
        (release_group_attribute_type_allowed_value IS NULL AND release_group_attribute_text IS NOT NULL)
        OR
        (release_group_attribute_type_allowed_value IS NOT NULL AND release_group_attribute_text IS NULL)
    )
);

CREATE TABLE release_group_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references release_group.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release_group_meta ( -- replicate
    id                  INTEGER NOT NULL, -- PK, references release_group.id CASCADE
    release_count       INTEGER NOT NULL DEFAULT 0,
    first_release_date_year   SMALLINT,
    first_release_date_month  SMALLINT,
    first_release_date_day    SMALLINT,
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER
);

CREATE TABLE release_group_tag ( -- replicate (verbose)
    release_group       INTEGER NOT NULL, -- PK, references release_group.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release_group_primary_type ( -- replicate
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references release_group_primary_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE release_group_secondary_type ( -- replicate
    id                  SERIAL NOT NULL, -- PK
    name                TEXT NOT NULL,
    parent              INTEGER, -- references release_group_secondary_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE release_group_secondary_type_join ( -- replicate (verbose)
    release_group INTEGER NOT NULL, -- PK, references release_group.id,
    secondary_type INTEGER NOT NULL, -- PK, references release_group_secondary_type.id
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE script ( -- replicate
    id                  SERIAL,
    iso_code            CHAR(4) NOT NULL, -- ISO 15924
    iso_number          CHAR(3) NOT NULL, -- ISO 15924
    name                VARCHAR(100) NOT NULL,
    frequency           INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE series ( -- replicate (verbose)
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

CREATE TABLE series_type ( -- replicate (verbose)
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    entity_type         VARCHAR(50) NOT NULL,
    parent              INTEGER, -- references series_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE series_ordering_type ( -- replicate (verbose)
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references series_ordering_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE series_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references series.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE series_alias_type ( -- replicate (verbose)
    id                  SERIAL, -- PK
    name                TEXT NOT NULL,
    parent              INTEGER, -- references series_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE series_alias ( -- replicate (verbose)
    id                  SERIAL, -- PK
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

CREATE TABLE series_annotation ( -- replicate (verbose)
    series              INTEGER NOT NULL, -- PK, references series.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE series_attribute_type ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL,
    parent              INTEGER, -- references series_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE series_attribute_type_allowed_value ( -- replicate (verbose)
    id                          SERIAL,  -- PK
    series_attribute_type       INTEGER NOT NULL, -- references series_attribute_type.id
    value                       TEXT,
    parent                      INTEGER, -- references series_attribute_type_allowed_value.id
    child_order                 INTEGER NOT NULL DEFAULT 0,
    description                 TEXT,
    gid                         uuid NOT NULL
);

CREATE TABLE series_attribute ( -- replicate (verbose)
    id                                  SERIAL,  -- PK
    series                              INTEGER NOT NULL, -- references series.id
    series_attribute_type               INTEGER NOT NULL, -- references series_attribute_type.id
    series_attribute_type_allowed_value INTEGER, -- references series_attribute_type_allowed_value.id
    series_attribute_text               TEXT
    CHECK (
        (series_attribute_type_allowed_value IS NULL AND series_attribute_text IS NOT NULL)
        OR
        (series_attribute_type_allowed_value IS NOT NULL AND series_attribute_text IS NULL)
    )
);

CREATE TABLE series_tag ( -- replicate (verbose)
    series              INTEGER NOT NULL, -- PK, references series.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE series_tag_raw (
    series              INTEGER NOT NULL, -- PK, references series.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    is_upvote           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE tag ( -- replicate (verbose)
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    ref_count           INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE tag_relation
(
    tag1                INTEGER NOT NULL, -- PK, references tag.id
    tag2                INTEGER NOT NULL, -- PK, references tag.id
    weight              INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CHECK (tag1 < tag2)
);

CREATE TABLE track ( -- replicate (verbose)
    id                  SERIAL,
    gid                 UUID NOT NULL,
    recording           INTEGER NOT NULL, -- references recording.id
    medium              INTEGER NOT NULL, -- references medium.id
    position            INTEGER NOT NULL,
    number              TEXT NOT NULL,
    name                VARCHAR NOT NULL,
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    length              INTEGER CHECK (length IS NULL OR length > 0),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_data_track       BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE track_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references track.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE track_raw ( -- replicate
    id                  SERIAL, -- PK
    release             INTEGER NOT NULL,   -- references release_raw.id
    title               VARCHAR(255) NOT NULL,
    artist              VARCHAR(255),   -- For VA albums, otherwise empty
    sequence            INTEGER NOT NULL
);

CREATE TABLE medium_index ( -- replicate
    medium              INTEGER, -- PK, references medium.id CASCADE
    toc                 CUBE
);

CREATE TABLE url ( -- replicate
    id                  SERIAL,
    gid                 UUID NOT NULL,
    url                 TEXT NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE url_gid_redirect ( -- replicate
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references url.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE vote
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    edit                INTEGER NOT NULL, -- references edit.id
    vote                SMALLINT NOT NULL,
    vote_time            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    superseded          BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE work ( -- replicate (verbose)
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                VARCHAR NOT NULL,
    type                INTEGER, -- references work_type.id
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE work_language ( -- replicate (verbose)
    work                INTEGER NOT NULL, -- PK, references work.id
    language            INTEGER NOT NULL, -- PK, references language.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE work_rating_raw
(
    work                INTEGER NOT NULL, -- PK, references work.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

CREATE TABLE work_tag_raw
(
    work                INTEGER NOT NULL, -- PK, references work.id
    editor              INTEGER NOT NULL, -- PK, references editor.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    is_upvote           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE work_alias_type ( -- replicate
    id                  SERIAL,
    name                TEXT NOT NULL,
    parent              INTEGER, -- references work_alias_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE work_alias ( -- replicate (verbose)
    id                  SERIAL,
    work                INTEGER NOT NULL, -- references work.id
    name                VARCHAR NOT NULL,
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references work_alias_type.id
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

CREATE TABLE work_annotation ( -- replicate (verbose)
    work                INTEGER NOT NULL, -- PK, references work.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE work_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references work.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE work_meta ( -- replicate
    id                  INTEGER NOT NULL, -- PK, references work.id CASCADE
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER
);

CREATE TABLE work_tag ( -- replicate (verbose)
    work                INTEGER NOT NULL, -- PK, references work.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE work_type ( -- replicate
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references work_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE work_attribute_type ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL,
    parent              INTEGER, -- references work_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE work_attribute_type_allowed_value ( -- replicate (verbose)
    id                  SERIAL,  -- PK
    work_attribute_type INTEGER NOT NULL, -- references work_attribute_type.id
    value               TEXT,
    parent              INTEGER, -- references work_attribute_type_allowed_value.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 uuid NOT NULL
);

CREATE TABLE work_attribute ( -- replicate (verbose)
    id                                  SERIAL,  -- PK
    work                                INTEGER NOT NULL, -- references work.id
    work_attribute_type                 INTEGER NOT NULL, -- references work_attribute_type.id
    work_attribute_type_allowed_value   INTEGER, -- references work_attribute_type_allowed_value.id
    work_attribute_text                 TEXT
    CHECK (
        (work_attribute_type_allowed_value IS NULL AND work_attribute_text IS NOT NULL)
        OR
        (work_attribute_type_allowed_value IS NOT NULL AND work_attribute_text IS NULL)
    )
);

COMMIT;

-- vi: set ts=4 sw=4 et :
