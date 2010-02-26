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

CREATE TABLE artist (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references artist_name.id
    sortname            INTEGER NOT NULL, -- references artist_name.id
    begindate_year      SMALLINT,
    begindate_month     SMALLINT,
    begindate_day       SMALLINT,
    enddate_year        SMALLINT,
    enddate_month       SMALLINT,
    enddate_day         SMALLINT,
    type                INTEGER, -- references artist_type.id
    country             INTEGER, -- references country.id
    gender              INTEGER, -- references gender.id
    comment             VARCHAR(255),
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE artist_alias
(
    id                  SERIAL,
    artist              INTEGER NOT NULL, -- references artist.id
    name                INTEGER NOT NULL, -- references artist_name.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE artist_annotation
(
    artist              INTEGER NOT NULL, -- PK, references artist.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE artist_meta
(
    id                  INTEGER NOT NULL, -- PK, references artist.id CASCADE
    lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    ratingcount         INTEGER
);

CREATE TABLE artist_tag
(
    artist              INTEGER NOT NULL, -- PK, references artist.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL
);

CREATE TABLE artist_credit (
    id                  SERIAL,
    name                INTEGER NOT NULL, -- references artist_name.id
    artistcount         SMALLINT NOT NULL,
    refcount            INTEGER DEFAULT 0
);

CREATE TABLE artist_credit_name (
    artist_credit       INTEGER NOT NULL, -- PK, references artist_credit.id CASCADE
    position            SMALLINT NOT NULL, -- PK
    artist              INTEGER NOT NULL, -- references artist.id CASCADE
    name                INTEGER NOT NULL, -- references artist_name.id
    joinphrase          VARCHAR(32)
);

CREATE TABLE artist_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    newid               INTEGER NOT NULL -- references artist.id
);

CREATE TABLE artist_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL
);

CREATE TABLE artist_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

CREATE TABLE dbmirror_Pending (
    SeqId               SERIAL,
    TableName           NAME NOT NULL,
    Op                  CHARACTER,
    XID                 INTEGER NOT NULL
);

CREATE TABLE dbmirror_PendingData (
    SeqId               INTEGER NOT NULL, -- PK
    IsKey               BOOLEAN NOT NULL, -- PK
    Data                VARCHAR
);

CREATE TABLE editor
(
    id                  SERIAL,
    name                VARCHAR(64) NOT NULL,
    password            VARCHAR(64) NOT NULL,
    privs               INTEGER DEFAULT 0,
    email               VARCHAR(64) DEFAULT NULL,
    website             VARCHAR(255) DEFAULT NULL,
    bio                 TEXT DEFAULT NULL,
    membersince         TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    emailconfirmdate    TIMESTAMP WITH TIME ZONE,
    lastlogindate       TIMESTAMP WITH TIME ZONE,
    editsaccepted       INTEGER DEFAULT 0,
    editsrejected       INTEGER DEFAULT 0,
    autoeditsaccepted   INTEGER DEFAULT 0,
    editsfailed         INTEGER DEFAULT 0
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
    artist              INTEGER NOT NULL, -- weakly references artist
    lasteditsent        INTEGER NOT NULL, -- weakly references edit
    deletedbyedit       INTEGER NOT NULL DEFAULT 0, -- weakly references edit
    mergedbyedit        INTEGER NOT NULL DEFAULT 0 -- weakly references edit
);

CREATE TABLE editor_subscribe_label
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    label               INTEGER NOT NULL, -- weakly references label
    lasteditsent        INTEGER NOT NULL, -- weakly references edit
    deletedbyedit       INTEGER NOT NULL DEFAULT 0, -- weakly references edit
    mergedbyedit        INTEGER NOT NULL DEFAULT 0 -- weakly references edit
);

CREATE TABLE editor_subscribe_editor
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id (the one who has subscribed)
    subscribededitor    INTEGER NOT NULL, -- references editor.id (the one being subscribed)
    lasteditsent        INTEGER NOT NULL  -- weakly references edit
);

CREATE TABLE editor_collection
(
    id                  SERIAL,
    editor              INTEGER NOT NULL -- references editor.id
);

CREATE TABLE editor_collection_release
(
    collection          INTEGER NOT NULL, -- PK, references editor_collection.id
    release             INTEGER NOT NULL -- PK, references release.id
);

CREATE TABLE cdtoc
(
    id                  SERIAL,
    discid              CHAR(28) NOT NULL,
    freedbid            CHAR(8) NOT NULL,
    trackcount          INTEGER NOT NULL,
    leadoutoffset       INTEGER NOT NULL,
    trackoffset         INTEGER[] NOT NULL,
    degraded            BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE clientversion
(
    id                  SERIAL,
    version             VARCHAR(64) NOT NULL
);

CREATE TABLE country (
    id                  SERIAL,
    isocode             VARCHAR(2) NOT NULL,
    name                VARCHAR(255) NOT NULL
);

CREATE TABLE currentstat
(
    id                  SERIAL,
    name                VARCHAR(100) NOT NULL,
    value               INTEGER NOT NULL,
    lastupdated         TIMESTAMP WITH TIME ZONE
);

CREATE TABLE gender (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

CREATE TABLE isrc
(
    id                  SERIAL,
    recording           INTEGER NOT NULL, -- references recording.id
    isrc                CHAR(12) NOT NULL,
    source              SMALLINT,
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE historicalstat
(
    id                  SERIAL,
    name                VARCHAR(100) NOT NULL,
    value               INTEGER NOT NULL,
    snapshotdate        DATE NOT NULL
);

CREATE TABLE l_artist_artist
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references artist.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_label
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references label.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_recording
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references recording.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references release.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references url.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references artist.id
    entity1             INTEGER NOT NULL, -- references work.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_label
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references label.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_recording
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references recording.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references release.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references url.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references label.id
    entity1             INTEGER NOT NULL, -- references work.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_recording_recording
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references recording.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_recording_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references release.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_recording_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_recording_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references url.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_recording_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references recording.id
    entity1             INTEGER NOT NULL, -- references work.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_release
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references release.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references url.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release.id
    entity1             INTEGER NOT NULL, -- references work.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_group_release_group
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release_group.id
    entity1             INTEGER NOT NULL, -- references release_group.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_group_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release_group.id
    entity1             INTEGER NOT NULL, -- references url.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_group_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references release_group.id
    entity1             INTEGER NOT NULL, -- references work.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_url_url
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references url.id
    entity1             INTEGER NOT NULL, -- references url.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_url_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references url.id
    entity1             INTEGER NOT NULL, -- references work.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_work_work
(
    id                  SERIAL,
    link                INTEGER NOT NULL, -- references link.id
    entity0             INTEGER NOT NULL, -- references work.id
    entity1             INTEGER NOT NULL, -- references work.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE label (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references label_name.id
    sortname            INTEGER NOT NULL, -- references label_name.id
    begindate_year      SMALLINT,
    begindate_month     SMALLINT,
    begindate_day       SMALLINT,
    enddate_year        SMALLINT,
    enddate_month       SMALLINT,
    enddate_day         SMALLINT,
    labelcode           INTEGER,
    type                INTEGER, -- references label_type.id
    country             INTEGER, -- references country.id
    comment             VARCHAR(255),
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE label_alias
(
    id                  SERIAL,
    label               INTEGER NOT NULL, -- references label.id
    name                INTEGER NOT NULL, -- references label_name.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE label_annotation
(
    label               INTEGER NOT NULL, -- PK, references label.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE label_meta
(
    id                  INTEGER NOT NULL, -- PK, references label.id CASCADE
    lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    ratingcount         INTEGER
);

CREATE TABLE label_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    newid               INTEGER NOT NULL -- references label.id
);

CREATE TABLE label_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL
);

CREATE TABLE label_tag
(
    label               INTEGER NOT NULL, -- PK, references label.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL
);

CREATE TABLE label_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

CREATE TABLE language
(
    id                  SERIAL,
    isocode_3t          CHAR(3) NOT NULL, -- ISO 639-2 (T)
    isocode_3b          CHAR(3) NOT NULL, -- ISO 639-2 (B)
    isocode_2           CHAR(2), -- ISO 639
    name                VARCHAR(100) NOT NULL,
    frequency           INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE link
(
    id                  SERIAL,
    link_type           INTEGER NOT NULL, -- references link_type.id
    begindate_year      SMALLINT,
    begindate_month     SMALLINT,
    begindate_day       SMALLINT,
    enddate_year        SMALLINT,
    enddate_month       SMALLINT,
    enddate_day         SMALLINT,
    attributecount      INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE link_attribute
(
    link                INTEGER NOT NULL, -- PK, references link.id
    attribute_type      INTEGER NOT NULL -- PK, references link_attribute_type.id
);

CREATE TABLE link_attribute_type
(
    id                  SERIAL,
    parent              INTEGER, -- references link_attribute_type.id
    root                INTEGER NOT NULL, -- references link_attribute_type.id
    childorder          INTEGER NOT NULL DEFAULT 0,
    gid                 UUID NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT
);

CREATE TABLE link_type
(
    id                  SERIAL,
    parent              INTEGER, -- references link_type.id
    childorder          INTEGER NOT NULL DEFAULT 0,
    gid                 UUID NOT NULL,
    entitytype0         VARCHAR(50),
    entitytype1         VARCHAR(50),
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    shortlinkphrase     VARCHAR(255) NOT NULL,
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE link_type_attribute_type
(
    link_type           INTEGER NOT NULL, -- PK, references link_type.id
    attribute_type      INTEGER NOT NULL, -- PK, references link_attribute_type.id
    min                 SMALLINT,
    max                 SMALLINT
);

CREATE TABLE medium
(
    id                  SERIAL,
    tracklist           INTEGER NOT NULL, -- references tracklist.id
    release             INTEGER NOT NULL, -- references release.id
    position            INTEGER NOT NULL,
    format              INTEGER, -- references medium_format.id
    name                VARCHAR(255),
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE medium_cdtoc
(
    id                  SERIAL,
    medium              INTEGER NOT NULL, -- references medium.id
    cdtoc               INTEGER NOT NULL, -- references cdtoc.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE medium_format
(
    id                  SERIAL,
    name                VARCHAR(100) NOT NULL,
    year                SMALLINT
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
    length              INTEGER,
    comment             VARCHAR(255),
    editpending         INTEGER NOT NULL DEFAULT 0
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
    ratingcount         INTEGER,
    lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE recording_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    newid               INTEGER NOT NULL -- references recording.id
);

CREATE TABLE recording_puid
(
    id                  SERIAL,
    puid                INTEGER NOT NULL, -- references puid.id
    recording           INTEGER NOT NULL, -- references recording.id
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE recording_tag
(
    recording           INTEGER NOT NULL, -- PK, references recording.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL
);

CREATE TABLE release (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references release_name.id
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    release_group       INTEGER NOT NULL, -- references release_group.id
    status              INTEGER, -- references release_status.id
    packaging           INTEGER, -- references release_packaging.id
    country             INTEGER, -- references country.id
    language            INTEGER, -- references language.id
    script              INTEGER, -- references script.id
    date_year           SMALLINT,
    date_month          SMALLINT,
    date_day            SMALLINT,
    barcode             VARCHAR(255),
    comment             VARCHAR(255),
    editpending         INTEGER NOT NULL DEFAULT 0,
    quality             SMALLINT NOT NULL DEFAULT -1
);

CREATE TABLE release_annotation
(
    release             INTEGER NOT NULL, -- PK, references release.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE release_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    newid               INTEGER NOT NULL -- references release.id
);

CREATE TABLE release_meta
(
    id                  INTEGER NOT NULL, -- PK, references release.id CASCADE
    lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    dateadded           TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    coverarturl         VARCHAR(255),
    infourl             VARCHAR(255),
    amazonasin          VARCHAR(10),
    amazonstore         VARCHAR(20)
);

CREATE TABLE release_label (
    id                  SERIAL,
    release             INTEGER NOT NULL, -- references release.id
    label               INTEGER, -- references label.id
    catno               VARCHAR(255)
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

CREATE TABLE release_group (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references release_name.id
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    type                INTEGER, -- references release_group_type.id
    comment             VARCHAR(255),
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE release_group_annotation
(
    release_group       INTEGER NOT NULL, -- PK, references release_group.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE release_group_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    newid               INTEGER NOT NULL -- references release_group.id
);

CREATE TABLE release_group_meta
(
    id                  INTEGER NOT NULL, -- PK, references release_group.id CASCADE
    lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    releasecount        INTEGER NOT NULL DEFAULT 0,
    firstreleasedate_year   SMALLINT,
    firstreleasedate_month  SMALLINT,
    firstreleasedate_day    SMALLINT,
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    ratingcount         INTEGER
);

CREATE TABLE release_group_tag
(
    release_group       INTEGER NOT NULL, -- PK, references release_group.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL
);

CREATE TABLE release_group_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

CREATE TABLE release_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL
);

CREATE TABLE script
(
    id                  SERIAL,
    isocode             CHAR(4) NOT NULL, -- ISO 15924
    isonumber           CHAR(3) NOT NULL, -- ISO 15924
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
    refcount            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE tag_relation
(
    tag1                INTEGER NOT NULL, -- PK, references tag.id
    tag2                INTEGER NOT NULL, -- PK, references tag.id
    weight              INTEGER NOT NULL,
    CHECK (tag1 < tag2)
);

CREATE TABLE track
(
    id                  SERIAL,
    recording           INTEGER NOT NULL, -- references recording.id
    tracklist           INTEGER NOT NULL, -- references tracklist.id
    position            INTEGER NOT NULL,
    name                INTEGER NOT NULL, -- references track_name.id
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    length              INTEGER,
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE track_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL
);

CREATE TABLE tracklist
(
    id                  SERIAL,
    trackcount          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE tracklist_index
(
    tracklist           INTEGER, -- PK
    tracks              INTEGER,
    toc                 CUBE
);

CREATE TABLE url
(
    id                  SERIAL,
    gid                 UUID NOT NULL,
    url                 VARCHAR(255) NOT NULL,
    description         TEXT,
    refcount            INTEGER NOT NULL DEFAULT 0,
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE work (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references work_name.id
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    type                INTEGER, -- references work_type.id
    iswc                CHAR(15),
    comment             VARCHAR(255),
    editpending         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE work_annotation
(
    work                INTEGER NOT NULL, -- PK, references work.id
    annotation          INTEGER NOT NULL -- PK, references annotation.id
);

CREATE TABLE work_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    newid               INTEGER NOT NULL -- references work.id
);

CREATE TABLE work_meta
(
    id                  INTEGER NOT NULL, -- PK, references work.id CASCADE
    lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    rating              SMALLINT CHECK (rating >= 0 AND rating <= 100),
    ratingcount         INTEGER
);

CREATE TABLE work_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL
);

CREATE TABLE work_tag
(
    work                INTEGER NOT NULL, -- PK, references work.id
    tag                 INTEGER NOT NULL, -- PK, references tag.id
    count               INTEGER NOT NULL
);

CREATE TABLE work_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

COMMIT;

-- vi: set ts=4 sw=4 et :
