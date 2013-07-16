\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE annotation
(
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

CREATE TABLE area_type (
    id                  SERIAL, -- PK
    name                VARCHAR(255) NOT NULL
);

CREATE TABLE area (
    id                  SERIAL, -- PK
    gid                 uuid NOT NULL,
    name                VARCHAR NOT NULL,
    sort_name           VARCHAR NOT NULL,
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
      )
);

CREATE TABLE area_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references area.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE area_alias_type (
    id SERIAL, -- PK,
    name TEXT NOT NULL
);

CREATE TABLE area_alias (
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
             CONSTRAINT primary_check
                 CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL)));

CREATE TABLE area_annotation (
    area        INTEGER NOT NULL, -- PK, references area.id
    annotation  INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE artist (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references artist_name.id
    sort_name           INTEGER NOT NULL, -- references artist_name.id
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

CREATE TABLE artist_deletion
(
    gid UUID NOT NULL, -- PK
    last_known_name INTEGER NOT NULL, -- references artist_name.id
    last_known_comment TEXT NOT NULL,
    deleted_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE artist_alias_type (
    id SERIAL,
    name TEXT NOT NULL
);

CREATE TABLE artist_alias
(
    id                  SERIAL,
    artist              INTEGER NOT NULL, -- references artist.id
    name                INTEGER NOT NULL, -- references artist_name.id
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references artist_alias_type.id
    sort_name           INTEGER NOT NULL, -- references artist_name.id
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    primary_for_locale  BOOLEAN NOT NULL DEFAULT false,
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

CREATE TABLE artist_annotation
(
    artist              INTEGER NOT NULL, -- PK, references artist.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE artist_ipi
(
    artist              INTEGER NOT NULL, -- PK, references artist.id
    ipi                 CHAR(11) NOT NULL CHECK (ipi ~ E'^\\d{11}$'), -- PK
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE artist_isni
(
    artist              INTEGER NOT NULL, -- PK, references artist.id
    isni                CHAR(16) NOT NULL CHECK (isni ~ E'^\\d{15}[\\dX]$'), -- PK
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE artist_meta
(
    id                  INTEGER NOT NULL, -- PK, references artist.id CASCADE
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER
);

CREATE TABLE artist_tag
(
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
    tag                 INTEGER NOT NULL -- PK, references tag.id
);

CREATE TABLE artist_credit (
    id                  SERIAL,
    name                INTEGER NOT NULL, -- references artist_name.id
    artist_count        SMALLINT NOT NULL,
    ref_count           INTEGER DEFAULT 0,
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE artist_credit_name (
    artist_credit       INTEGER NOT NULL, -- PK, references artist_credit.id CASCADE
    position            SMALLINT NOT NULL, -- PK
    artist              INTEGER NOT NULL, -- references artist.id CASCADE
    name                INTEGER NOT NULL, -- references artist_name.id
    join_phrase         TEXT NOT NULL DEFAULT ''
);

CREATE TABLE artist_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references artist.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE artist_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL
);

CREATE TABLE artist_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
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

CREATE TABLE cdtoc
(
    id                  SERIAL,
    discid              CHAR(28) NOT NULL,
    freedb_id           CHAR(8) NOT NULL,
    track_count         INTEGER NOT NULL,
    leadout_offset      INTEGER NOT NULL,
    track_offset        INTEGER[] NOT NULL,
    degraded            BOOLEAN NOT NULL DEFAULT FALSE,
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE cdtoc_raw
(
    id                  SERIAL,
    release             INTEGER NOT NULL, -- references release_raw.id
    discid              CHAR(28) NOT NULL,
    track_count          INTEGER NOT NULL,
    leadout_offset       INTEGER NOT NULL,
    track_offset         INTEGER[] NOT NULL
);

CREATE TABLE clientversion
(
    id                  SERIAL,
    version             VARCHAR(64) NOT NULL,
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE country_area
(
    area                INTEGER -- PK, references area.id
);

CREATE TABLE edit
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    type                SMALLINT NOT NULL,
    status              SMALLINT NOT NULL,
    data                TEXT NOT NULL,
    yes_votes            INTEGER NOT NULL DEFAULT 0,
    no_votes             INTEGER NOT NULL DEFAULT 0,
    autoedit            SMALLINT NOT NULL DEFAULT 0,
    open_time            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    close_time           TIMESTAMP WITH TIME ZONE,
    expire_time          TIMESTAMP WITH TIME ZONE NOT NULL,
    language            INTEGER, -- references language
    quality             SMALLINT NOT NULL DEFAULT 1
);

CREATE TABLE edit_note
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    edit                INTEGER NOT NULL, -- references edit.id
    text                TEXT NOT NULL,
    post_time            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
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

CREATE TABLE edit_label
(
    edit                INTEGER NOT NULL, -- PK, references edit.id
    label               INTEGER NOT NULL, -- PK, references label.id CASCADE
    status              SMALLINT NOT NULL -- materialized from edit.status
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
    edits_accepted      INTEGER DEFAULT 0,
    edits_rejected      INTEGER DEFAULT 0,
    auto_edits_accepted INTEGER DEFAULT 0,
    edits_failed        INTEGER DEFAULT 0,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    birth_date          DATE,
    gender              INTEGER, -- references gender.id
    area                INTEGER, -- references area.id
    password            VARCHAR(128) NOT NULL,
    ha1                 CHAR(32) NOT NULL
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
    gid UUID NOT NULL, -- PK, references artist_deletion.gid
    deleted_by INTEGER NOT NULL -- references edit.id
);

CREATE TABLE editor_subscribe_collection
(
    id                  SERIAL,
    editor              INTEGER NOT NULL,              -- references editor.id
    collection          INTEGER NOT NULL,              -- weakly references collection
    last_edit_sent      INTEGER NOT NULL,              -- weakly references edit
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
    gid UUID NOT NULL, -- PK, references label_deletion.gid
    deleted_by INTEGER NOT NULL -- references edit.id
);

CREATE TABLE editor_subscribe_editor
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id (the one who has subscribed)
    subscribed_editor   INTEGER NOT NULL, -- references editor.id (the one being subscribed)
    last_edit_sent      INTEGER NOT NULL  -- weakly references edit
);

CREATE TABLE gender (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

CREATE TABLE iso_3166_1 (
    area      INTEGER NOT NULL, -- references area.id
    code      CHAR(2) -- PK
);
CREATE TABLE iso_3166_2 (
    area      INTEGER NOT NULL, -- references area.id
    code      VARCHAR(10) -- PK
);
CREATE TABLE iso_3166_3 (
    area      INTEGER NOT NULL, -- references area.id
    code      CHAR(4) -- PK
);

CREATE TABLE isrc
(
    id                  SERIAL,
    recording           INTEGER NOT NULL, -- references recording.id
    isrc                CHAR(12) NOT NULL CHECK (isrc ~ E'^[A-Z]{2}[A-Z0-9]{3}[0-9]{7}$'),
    source              SMALLINT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE iswc (
    id SERIAL NOT NULL,
    work INTEGER NOT NULL, -- references work.id
    iswc CHARACTER(15) CHECK (iswc ~ E'^T-?\\d{3}.?\\d{3}.?\\d{3}[-.]?\\d$'),
    source SMALLINT,
    edits_pending INTEGER NOT NULL DEFAULT 0,
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE l_area_area
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references area.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_area_artist
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references artist.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_area_label
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references label.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_area_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_area_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_area_recording
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_area_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_area_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references area.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_artist_artist
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references artist.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_artist_label
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references label.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_artist_recording
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_artist_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_artist_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_artist_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_artist_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_label_label
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references label.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_label_recording
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_label_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_label_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_label_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_label_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_recording_recording
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_recording_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_recording_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_recording_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_recording_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_release_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references release.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_release_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_release_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_release_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_release_group_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release_group.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_release_group_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release_group.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_release_group_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release_group.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_url_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references url.id
    entity1             INTEGER NOT NULL, -- references url.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_url_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references url.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE l_work_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references work.id
    entity1             INTEGER NOT NULL, -- references work.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE label (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references label_name.id
    sort_name           INTEGER NOT NULL, -- references label_name.id
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

CREATE TABLE label_deletion
(
    gid UUID NOT NULL, -- PK
    last_known_name INTEGER NOT NULL, -- references label_name.id
    last_known_comment TEXT NOT NULL,
    deleted_at timestamptz NOT NULL DEFAULT now()
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
    tag                 INTEGER NOT NULL -- PK, references tag.id
);

CREATE TABLE label_alias_type (
    id SERIAL,
    name TEXT NOT NULL
);

CREATE TABLE label_alias
(
    id                  SERIAL,
    label               INTEGER NOT NULL, -- references label.id
    name                INTEGER NOT NULL, -- references label_name.id
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references label_alias_type.id
    sort_name           INTEGER NOT NULL, -- references label_name.id
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    primary_for_locale  BOOLEAN NOT NULL DEFAULT false,
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

CREATE TABLE label_annotation
(
    label               INTEGER NOT NULL, -- PK, references label.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE label_ipi
(
    label               INTEGER NOT NULL, -- PK, references label.id
    ipi                 CHAR(11) NOT NULL CHECK (ipi ~ E'^\\d{11}$'), -- PK
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE label_isni
(
    label               INTEGER NOT NULL, -- PK, references label.id
    isni                CHAR(16) NOT NULL CHECK (isni ~ E'^\\d{15}[\\dX]$'), -- PK
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE label_meta
(
    id                  INTEGER NOT NULL, -- PK, references label.id CASCADE
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER
);

CREATE TABLE label_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references label.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE label_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL
);

CREATE TABLE label_tag
(
    label               INTEGER NOT NULL, -- PK, references label.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE label_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

CREATE TABLE language
(
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

CREATE TABLE link
(
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

CREATE TABLE link_attribute
(
    link                INTEGER NOT NULL, -- PK, references link.id
    attribute_type      INTEGER NOT NULL, -- PK, references link_attribute_type.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE link_attribute_type
(
    id                  SERIAL,
    parent              INTEGER, -- references link_attribute_type.id
    root                INTEGER NOT NULL, -- references link_attribute_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    gid                 UUID NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE link_creditable_attribute_type (
  attribute_type INT NOT NULL -- PK, references link_attribute_type.id CASCADE
);

CREATE TABLE link_attribute_credit (
  link INT NOT NULL, -- PK, references link.id
  attribute_type INT NOT NULL, -- PK, references link_creditable_attribute_type.attribute_type
  credited_as TEXT NOT NULL
);

CREATE TABLE link_type
(
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
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE link_type_attribute_type
(
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
    description         TEXT DEFAULT '' NOT NULL
);

CREATE TABLE editor_collection_release
(
    collection          INTEGER NOT NULL, -- PK, references editor_collection.id
    release             INTEGER NOT NULL -- PK, references release.id
);

CREATE TABLE editor_oauth_token
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    application         INTEGER NOT NULL, -- references application.id
    authorization_code  TEXT,
    refresh_token       TEXT,
    access_token        TEXT,
    mac_key             TEXT,
    mac_time_diff       INTEGER,
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

CREATE TABLE medium
(
    id                  SERIAL,
    release             INTEGER NOT NULL, -- references release.id
    position            INTEGER NOT NULL,
    format              INTEGER, -- references medium_format.id
    name                VARCHAR(255),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    track_count         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE medium_cdtoc
(
    id                  SERIAL,
    medium              INTEGER NOT NULL, -- references medium.id
    cdtoc               INTEGER NOT NULL, -- references cdtoc.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE medium_format
(
    id                  SERIAL,
    name                VARCHAR(100) NOT NULL,
    parent              INTEGER, -- references medium_format.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    year                SMALLINT,
    has_discids         BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE puid
(
    id                  SERIAL,
    puid                CHAR(36) NOT NULL,
    version             INTEGER NOT NULL -- references clientversion.id
);

CREATE TABLE replication_control
(
    id                              SERIAL,
    current_schema_sequence         INTEGER NOT NULL,
    current_replication_sequence    INTEGER,
    last_replication_date           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE recording (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references track_name.id
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    length              INTEGER CHECK (length IS NULL OR length > 0),
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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
    tag                 INTEGER NOT NULL -- PK, references tag.id
);

CREATE TABLE recording_annotation
(
    recording           INTEGER NOT NULL, -- PK, references recording.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE recording_meta
(
    id                  INTEGER NOT NULL, -- PK, references recording.id CASCADE
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER
);

CREATE TABLE recording_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references recording.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE recording_puid
(
    id                  SERIAL,
    puid                INTEGER NOT NULL, -- references puid.id
    recording           INTEGER NOT NULL, -- references recording.id
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE recording_tag
(
    recording           INTEGER NOT NULL, -- PK, references recording.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references release_name.id
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

CREATE TABLE release_country (
  release INTEGER NOT NULL,  -- PK, references release.id
  country INTEGER NOT NULL,  -- PK, references country_area.area
  date_year SMALLINT,
  date_month SMALLINT,
  date_day SMALLINT
);

CREATE TABLE release_unknown_country (
  release INTEGER NOT NULL,  -- PK, references release.id
  date_year SMALLINT,
  date_month SMALLINT,
  date_day SMALLINT
);

CREATE TABLE release_raw
(
    id                  SERIAL,
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
    tag                 INTEGER NOT NULL -- PK, references tag.id
);

CREATE TABLE release_annotation
(
    release             INTEGER NOT NULL, -- PK, references release.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE release_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references release.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TYPE cover_art_presence AS ENUM ('absent', 'present', 'darkened');

CREATE TABLE release_meta
(
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

CREATE TABLE release_label (
    id                  SERIAL,
    release             INTEGER NOT NULL, -- references release.id
    label               INTEGER, -- references label.id
    catalog_number      VARCHAR(255),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release_packaging
(
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

CREATE TABLE release_status
(
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

CREATE TABLE release_tag
(
    release             INTEGER NOT NULL, -- PK, references release.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release_group (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references release_name.id
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    type                INTEGER, -- references release_group_primary_type.id
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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
    tag                 INTEGER NOT NULL -- PK, references tag.id
);

CREATE TABLE release_group_annotation
(
    release_group       INTEGER NOT NULL, -- PK, references release_group.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE release_group_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references release_group.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release_group_meta
(
    id                  INTEGER NOT NULL, -- PK, references release_group.id CASCADE
    release_count       INTEGER NOT NULL DEFAULT 0,
    first_release_date_year   SMALLINT,
    first_release_date_month  SMALLINT,
    first_release_date_day    SMALLINT,
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER
);

CREATE TABLE release_group_tag
(
    release_group       INTEGER NOT NULL, -- PK, references release_group.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE release_group_primary_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

CREATE TABLE release_group_secondary_type (
    id SERIAL NOT NULL, -- pk
    name TEXT NOT NULL
);

CREATE TABLE release_group_secondary_type_join (
    release_group INTEGER NOT NULL, -- PK, references release_group.id,
    secondary_type INTEGER NOT NULL, -- PK, references release_group_secondary_type.id
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE release_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL
);

CREATE TABLE script
(
    id                  SERIAL,
    iso_code            CHAR(4) NOT NULL, -- ISO 15924
    iso_number          CHAR(3) NOT NULL, -- ISO 15924
    name                VARCHAR(100) NOT NULL,
    frequency           INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE script_language
(
    id                  SERIAL,
    script              INTEGER NOT NULL, -- references script.id
    language            INTEGER NOT NULL, -- references language.id
    frequency           INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE tag
(
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

CREATE TABLE track
(
    id                  SERIAL,
    gid                 UUID NOT NULL,
    recording           INTEGER NOT NULL, -- references recording.id
    medium              INTEGER NOT NULL, -- references medium.id
    position            INTEGER NOT NULL,
    number              TEXT NOT NULL,
    name                INTEGER NOT NULL, -- references track_name.id
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    length              INTEGER CHECK (length IS NULL OR length > 0),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE track_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references track.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE track_raw
(
    id                  SERIAL,
    release             INTEGER NOT NULL,   -- references release_raw.id
    title               VARCHAR(255) NOT NULL,
    artist              VARCHAR(255),   -- For VA albums, otherwise empty
    sequence            INTEGER NOT NULL
);

CREATE TABLE track_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL
);

CREATE TABLE medium_index
(
    medium              INTEGER, -- PK, references medium.id CASCADE
    toc                 CUBE
);

CREATE TABLE url
(
    id                  SERIAL,
    gid                 UUID NOT NULL,
    url                 TEXT NOT NULL,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE url_gid_redirect
(
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

CREATE TABLE work (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references work_name.id
    type                INTEGER, -- references work_type.id
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    language            INTEGER  -- references language.id
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
    tag                 INTEGER NOT NULL -- PK, references tag.id
);

CREATE TABLE work_alias_type (
    id SERIAL,
    name TEXT NOT NULL
);

CREATE TABLE work_alias
(
    id                  SERIAL,
    work                INTEGER NOT NULL, -- references work.id
    name                INTEGER NOT NULL, -- references work_name.id
    locale              TEXT,
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type                INTEGER, -- references work_alias_type.id
    sort_name           INTEGER NOT NULL, -- references work_name.id
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    primary_for_locale  BOOLEAN NOT NULL DEFAULT false,
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

CREATE TABLE work_annotation
(
    work                INTEGER NOT NULL, -- PK, references work.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE work_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references work.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE work_meta
(
    id                  INTEGER NOT NULL, -- PK, references work.id CASCADE
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    rating_count        INTEGER
);

CREATE TABLE work_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL
);

CREATE TABLE work_tag
(
    work                INTEGER NOT NULL, -- PK, references work.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL,
    last_updated        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE work_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

CREATE TABLE work_attribute_type (
    id                  SERIAL,  -- PK
    name                VARCHAR(255) NOT NULL,
    comment             VARCHAR(255) NOT NULL DEFAULT '',
    free_text           BOOLEAN NOT NULL
);

CREATE TABLE work_attribute_type_allowed_value (
    id                  SERIAL,  -- PK
    work_attribute_type INTEGER NOT NULL, -- references work_attribute_type.id
    value               TEXT
);

CREATE TABLE work_attribute (
    id                                  SERIAL,  -- PK
    work                                INTEGER NOT NULL, -- references work.id
    work_attribute_type                 INTEGER NOT NULL, -- references work_attribute_type.id
    work_attribute_type_allowed_value   INTEGER, -- references work_attribute_type_allowed_value.id
    work_attribute_text                 TEXT
    -- Either it has a value from the allowed list, or is free text
    CHECK ( work_attribute_type_allowed_value IS NULL OR work_attribute_text IS NULL )
);

COMMIT;

-- vi: set ts=4 sw=4 et :
