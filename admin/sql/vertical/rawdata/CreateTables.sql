\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE edit
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- weakly references editor
    type                SMALLINT NOT NULL,
    status              SMALLINT NOT NULL,
    data                XML NOT NULL,
    yesvotes            INTEGER NOT NULL DEFAULT 0,
    novotes             INTEGER NOT NULL DEFAULT 0,
    autoedit            SMALLINT NOT NULL DEFAULT 0,
    opentime            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    closetime           TIMESTAMP WITH TIME ZONE,
    expiretime          TIMESTAMP WITH TIME ZONE NOT NULL,
    language            INTEGER, -- references language
    quality             SMALLINT NOT NULL DEFAULT 1
);

CREATE TABLE edit_note
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- weakly references editor
    edit                INTEGER NOT NULL, -- references edit.id
    text                TEXT NOT NULL,
    notetime            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE edit_artist
(
    edit                INTEGER NOT NULL, -- PK
    artist              INTEGER NOT NULL -- PK
);

CREATE TABLE edit_label
(
    edit                INTEGER NOT NULL, -- PK
    label               INTEGER NOT NULL -- PK
);

CREATE TABLE edit_release
(
    edit                INTEGER NOT NULL, -- PK
    release             INTEGER NOT NULL -- PK
);

CREATE TABLE edit_release_group
(
    edit                INTEGER NOT NULL, -- PK
    release_group       INTEGER NOT NULL -- PK
);

CREATE TABLE edit_recording
(
    edit                INTEGER NOT NULL, -- PK
    recording           INTEGER NOT NULL -- PK
);

CREATE TABLE edit_work
(
    edit                INTEGER NOT NULL, -- PK
    work                INTEGER NOT NULL -- PK
);

CREATE TABLE edit_url
(
    edit                INTEGER NOT NULL, -- PK
    url                 INTEGER NOT NULL -- PK
);

CREATE TABLE vote
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- weakly references editor
    edit                INTEGER NOT NULL, -- references edit.id
    vote                SMALLINT NOT NULL,
    votetime            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    superseded          BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE artist_rating_raw
(
    artist              INTEGER NOT NULL, -- PK
    editor              INTEGER NOT NULL, -- PK
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

CREATE TABLE artist_tag_raw
(
    artist              INTEGER NOT NULL, -- PK
    editor              INTEGER NOT NULL, -- PK
    tag                 INTEGER NOT NULL -- PK
);

CREATE TABLE cdtoc_raw
(
    id                  SERIAL,
    release             INTEGER NOT NULL, -- references release_raw.id
    discid              CHAR(28) NOT NULL,
    trackcount          INTEGER NOT NULL,
    leadoutoffset       INTEGER NOT NULL,
    trackoffset         INTEGER[] NOT NULL
);

CREATE TABLE label_rating_raw
(
    label               INTEGER NOT NULL, -- PK
    editor              INTEGER NOT NULL, -- PK
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

CREATE TABLE label_tag_raw
(
    label               INTEGER NOT NULL, -- PK
    editor              INTEGER NOT NULL, -- PK
    tag                 INTEGER NOT NULL -- PK
);

CREATE TABLE release_raw
(
    id                  SERIAL,
    title               VARCHAR(255) NOT NULL,
    artist              VARCHAR(255),
    added               TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    lastmodified        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    lookupcount         INTEGER DEFAULT 0,
    modifycount         INTEGER DEFAULT 0,
    source              INTEGER DEFAULT 0,
    barcode             VARCHAR(255),
    comment             VARCHAR(255)
);

CREATE TABLE release_group_rating_raw
(
    release_group       INTEGER NOT NULL, -- PK
    editor              INTEGER NOT NULL, -- PK
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

CREATE TABLE release_group_tag_raw
(
    release_group       INTEGER NOT NULL, -- PK
    editor              INTEGER NOT NULL, -- PK
    tag                 INTEGER NOT NULL -- PK
);

CREATE TABLE recording_rating_raw
(
    recording           INTEGER NOT NULL, -- PK
    editor              INTEGER NOT NULL, -- PK
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

CREATE TABLE recording_tag_raw
(
    recording           INTEGER NOT NULL, -- PK
    editor              INTEGER NOT NULL, -- PK
    tag                 INTEGER NOT NULL -- PK
);

CREATE TABLE work_rating_raw
(
    work                INTEGER NOT NULL, -- PK
    editor              INTEGER NOT NULL, -- PK
    rating              SMALLINT NOT NULL CHECK (rating >= 0 AND rating <= 100)
);

CREATE TABLE work_tag_raw
(
    work                INTEGER NOT NULL, -- PK
    editor              INTEGER NOT NULL, -- PK
    tag                 INTEGER NOT NULL -- PK
);

CREATE TABLE track_raw
(
    id                  SERIAL,
    release             INTEGER NOT NULL,   -- references release_raw.id
    title               VARCHAR(255) NOT NULL,
    artist              VARCHAR(255),   -- For VA albums, otherwise empty
    sequence            INTEGER NOT NULL
);

COMMIT;

-- vi: set ts=4 sw=4 et :
