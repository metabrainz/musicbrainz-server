\set ON_ERROR_STOP 1
BEGIN;

-- A quick crib sheet: when adding a table to the system, quite a few files
-- will need modification.  This isn't a complete list, but should serve as a
-- handy reminder as to most of the files involved:
--   admin/sql/(Create|Drop)Tables.sql
--   admin/sql/(Create|Drop)PrimaryKeys.sql
--   admin/sql/(Create|Drop)Indexes.sql
--   admin/sql/(Create|Drop)FKConstraints.sql
--   admin/sql/(Create|Drop)ReplicationTriggers.sql
--   admin/SetSequences.pl
--   admin/ExportAllTables
--   admin/MBImport.pl
--   admin/replication/LoadReplicationChanges (if not replicated)

-- Add tables in alphabetical order please!

CREATE TABLE album
(
    id                  SERIAL,
    artist              INTEGER NOT NULL, -- references artist
    name                VARCHAR(255) NOT NULL,
    gid                 CHAR(36) NOT NULL, 
    modpending          INTEGER DEFAULT 0,
    attributes          INTEGER[] DEFAULT '{0}',
    page                INTEGER NOT NULL,
    language            INTEGER, -- references language
    script              INTEGER, -- references script
    modpending_lang     INTEGER,
    quality             SMALLINT DEFAULT -1,
    modpending_qual     INTEGER DEFAULT 0
);

CREATE TABLE album_amazon_asin
(
    album               INTEGER NOT NULL, -- references album
    asin                CHAR(10),
    coverarturl         VARCHAR(255),
    lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE album_cdtoc
(
    id                  SERIAL,
    album               INTEGER NOT NULL,
    cdtoc               INTEGER NOT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE albumjoin
(
    id                  SERIAL,
    album               INTEGER NOT NULL, -- references album
    track               INTEGER NOT NULL, -- references track
    sequence            INTEGER NOT NULL,
    modpending          INTEGER DEFAULT 0
);

CREATE TABLE albummeta
(
    id                  INTEGER NOT NULL,
    tracks              INTEGER DEFAULT 0,
    discids             INTEGER DEFAULT 0,
    puids               INTEGER DEFAULT 0,
    firstreleasedate    CHAR(10),
    asin                CHAR(10),
    coverarturl         VARCHAR(255),
    lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    dateadded           TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    rating              REAL,
    rating_count        INTEGER
);

CREATE TABLE albumwords
(
    wordid              INTEGER NOT NULL,
    albumid             INTEGER NOT NULL
);

CREATE TABLE annotation
(
    id                  SERIAL,
    moderator           INTEGER NOT NULL, -- references moderator
    type                SMALLINT NOT NULL,
    rowid               INTEGER NOT NULL, -- conditional reference
    text                TEXT,
    changelog           VARCHAR(255),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    moderation          INTEGER NOT NULL DEFAULT 0,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE artist
(
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    gid                 CHAR(36) NOT NULL,
    modpending          INTEGER DEFAULT 0,
    sortname            VARCHAR(255) NOT NULL,
    page                INTEGER NOT NULL,
    resolution          VARCHAR(64),
    begindate           CHAR(10),
    enddate             CHAR(10),
    type                SMALLINT,
    quality             SMALLINT DEFAULT -1,
    modpending_qual     INTEGER DEFAULT 0
);

CREATE TABLE artist_meta
(
    id                  INTEGER NOT NULL,
    lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    rating              REAL,
    rating_count        INTEGER
);

CREATE TABLE artistalias
(
    id                  SERIAL,
    ref                 INTEGER NOT NULL, -- references artist
    name                VARCHAR(255) NOT NULL, 
    timesused           INTEGER DEFAULT 0,
    modpending          INTEGER DEFAULT 0,
    lastused            TIMESTAMP WITH TIME ZONE
);

CREATE TABLE artist_relation
(
    id                  SERIAL,
    artist              INTEGER NOT NULL, -- references artist
    ref                 INTEGER NOT NULL, -- references artist
    weight              INTEGER NOT NULL
);

CREATE TABLE artist_tag
(
     artist              INTEGER NOT NULL,
     tag                 INTEGER NOT NULL,
     count               INTEGER NOT NULL
);

CREATE TABLE artistwords
(
    wordid              INTEGER NOT NULL,
    artistid            INTEGER NOT NULL
);

CREATE TABLE labelwords
(
    wordid              INTEGER NOT NULL,
    labelid            INTEGER NOT NULL
);

CREATE TABLE automod_election
(
    id                  SERIAL,
    candidate           INTEGER NOT NULL,
    proposer            INTEGER NOT NULL,
    seconder_1          INTEGER,
    seconder_2          INTEGER,
    status              INTEGER NOT NULL DEFAULT 1
        CONSTRAINT automod_election_chk1 CHECK (status IN (1,2,3,4,5,6)),
        -- 1 : has proposer
        -- 2 : has seconder_1
        -- 3 : has seconder_2 (voting open)
        -- 4 : accepted!
        -- 5 : rejected
        -- 6 : cancelled (by proposer)
    yesvotes            INTEGER NOT NULL DEFAULT 0,
    novotes             INTEGER NOT NULL DEFAULT 0,
    proposetime         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    opentime            TIMESTAMP WITH TIME ZONE,
    closetime           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE automod_election_vote
(
    id                  SERIAL,
    automod_election    INTEGER NOT NULL,
    voter               INTEGER NOT NULL,
    vote                INTEGER NOT NULL,
        CONSTRAINT automod_election_vote_chk1 CHECK (vote IN (-1,0,1)),
    votetime            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
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

CREATE TABLE country
(
    id                  SERIAL,
    isocode             VARCHAR(2) NOT NULL,
    name                VARCHAR(100) NOT NULL
);

CREATE TABLE currentstat
(
    id                  SERIAL,
    name                VARCHAR(100) NOT NULL,
    value               INTEGER NOT NULL,
    lastupdated         TIMESTAMP WITH TIME ZONE
);

CREATE TABLE historicalstat
(
    id                  SERIAL,
    name                VARCHAR(100) NOT NULL,
    value               INTEGER NOT NULL,
    snapshotdate        DATE NOT NULL
);

CREATE TABLE label
(
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    gid                 CHAR(36) NOT NULL,
    modpending          INTEGER DEFAULT 0,
    labelcode           INTEGER,
    sortname            VARCHAR(255) NOT NULL,
    country             INTEGER, -- references country
    page                INTEGER NOT NULL,
    resolution          VARCHAR(64),
    begindate           CHAR(10),
    enddate             CHAR(10),
    type                SMALLINT
);

CREATE TABLE label_meta
(
    id                  INTEGER NOT NULL,
    lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    rating              REAL,
    rating_count        INTEGER
);

CREATE TABLE label_tag
(
    label               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    count               INTEGER NOT NULL
);

CREATE TABLE gid_redirect
(
    gid                 CHAR(36) NOT NULL,
    newid               INTEGER NOT NULL,
    tbl                 SMALLINT NOT NULL
);

CREATE TABLE l_album_album
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references album
    link1               INTEGER NOT NULL DEFAULT 0, -- references album
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_album_album
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_album_artist
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references album
    link1               INTEGER NOT NULL DEFAULT 0, -- references artist
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_album_artist
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_album_label
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references album
    link1               INTEGER NOT NULL DEFAULT 0, -- references label
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_album_label
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_album_track
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references album
    link1               INTEGER NOT NULL DEFAULT 0, -- references track
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_album_track
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_album_url
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references album
    link1               INTEGER NOT NULL DEFAULT 0, -- references url
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_album_url
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_artist
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references artist
    link1               INTEGER NOT NULL DEFAULT 0, -- references artist
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_artist_artist
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_label
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references artist
    link1               INTEGER NOT NULL DEFAULT 0, -- references label
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_artist_label
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_track
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references artist
    link1               INTEGER NOT NULL DEFAULT 0, -- references track
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_artist_track
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_url
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references artist
    link1               INTEGER NOT NULL DEFAULT 0, -- references url
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_artist_url
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_label
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references label
    link1               INTEGER NOT NULL DEFAULT 0, -- references label
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_label_label
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_track
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references label
    link1               INTEGER NOT NULL DEFAULT 0, -- references track
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_label_track
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_url
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references label
    link1               INTEGER NOT NULL DEFAULT 0, -- references url
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_label_url
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_track_track
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references track
    link1               INTEGER NOT NULL DEFAULT 0, -- references track
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_track_track
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_track_url
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references track
    link1               INTEGER NOT NULL DEFAULT 0, -- references url
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_track_url
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_url_url
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references track
    link1               INTEGER NOT NULL DEFAULT 0, -- references url
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_track_url
    begindate           CHAR(10) DEFAULT NULL,
    enddate             CHAR(10) DEFAULT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE labelalias
(
    id                  SERIAL,
    ref                 INTEGER NOT NULL, -- references label
    name                VARCHAR(255) NOT NULL, 
    timesused           INTEGER DEFAULT 0,
    modpending          INTEGER DEFAULT 0,
    lastused            TIMESTAMP WITH TIME ZONE
);

CREATE TABLE language
(
     id                 SERIAL,
     isocode_3t         CHAR(3) NOT NULL, -- ISO 639-2 (T)
     isocode_3b         CHAR(3) NOT NULL, -- ISO 639-2 (B)
     isocode_2          CHAR(2), -- ISO 639
     name               VARCHAR(100) NOT NULL,
     french_name        VARCHAR(100) NOT NULL,
     frequency          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE link_attribute
(
    id                  SERIAL,
    attribute_type      INTEGER NOT NULL DEFAULT 0, -- references link_attribute_type
    link                INTEGER NOT NULL DEFAULT 0, -- references l_<ent>_<ent> without FK
    link_type           VARCHAR(32) NOT NULL DEFAULT '' -- indicates which l_ table to refer to
);

CREATE TABLE link_attribute_type
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_album_album
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_album_artist
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_album_label
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_album_track
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_album_url
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_artist_artist
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_artist_label
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_artist_track
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_artist_url
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_label_label
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_label_track
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_label_url
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_track_track
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_track_url
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE lt_url_url
(
    id                  SERIAL,
    parent              INTEGER NOT NULL, -- references self
    childorder          INTEGER NOT NULL DEFAULT 0,
    mbid                CHAR(36) NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    linkphrase          VARCHAR(255) NOT NULL,
    rlinkphrase         VARCHAR(255) NOT NULL,
    attribute           VARCHAR(255) DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0,
    shortlinkphrase     VARCHAR(255) NOT NULL DEFAULT '',
    priority            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE moderation_note_closed
(
    id                  INTEGER NOT NULL,
    moderation          INTEGER NOT NULL, 
    moderator           INTEGER NOT NULL, 
    text                TEXT NOT NULL,
    notetime		TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE moderation_note_open
(
    id                  SERIAL NOT NULL,
    moderation          INTEGER NOT NULL, 
    moderator           INTEGER NOT NULL, 
    text                TEXT NOT NULL,
    notetime		TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE moderation_closed
(
    id                  INTEGER NOT NULL,
    artist              INTEGER NOT NULL, -- references artist
    moderator           INTEGER NOT NULL, -- references moderator
    tab                 VARCHAR(32) NOT NULL,
    col                 VARCHAR(64) NOT NULL, 
    type                SMALLINT NOT NULL, 
    status              SMALLINT NOT NULL, 
    rowid               INTEGER NOT NULL, 
    prevvalue           TEXT NOT NULL, 
    newvalue            TEXT NOT NULL, 
    yesvotes            INTEGER DEFAULT 0, 
    novotes             INTEGER DEFAULT 0,
    depmod              INTEGER DEFAULT 0,
    automod             SMALLINT DEFAULT 0,
    opentime            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    closetime           TIMESTAMP WITH TIME ZONE,
    expiretime          TIMESTAMP WITH TIME ZONE NOT NULL,
    language            INTEGER -- references language
);

CREATE TABLE moderation_open
(
    id                  SERIAL NOT NULL,
    artist              INTEGER NOT NULL, -- references artist
    moderator           INTEGER NOT NULL, -- references moderator
    tab                 VARCHAR(32) NOT NULL,
    col                 VARCHAR(64) NOT NULL, 
    type                SMALLINT NOT NULL, 
    status              SMALLINT NOT NULL, 
    rowid               INTEGER NOT NULL, 
    prevvalue           TEXT NOT NULL, 
    newvalue            TEXT NOT NULL, 
    yesvotes            INTEGER DEFAULT 0, 
    novotes             INTEGER DEFAULT 0,
    depmod              INTEGER DEFAULT 0,
    automod             SMALLINT DEFAULT 0,
    opentime            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    closetime           TIMESTAMP WITH TIME ZONE,
    expiretime          TIMESTAMP WITH TIME ZONE NOT NULL,
    language            INTEGER -- references language
);

CREATE TABLE moderator
(
    id                  SERIAL,
    name                VARCHAR(64) NOT NULL,
    password            VARCHAR(64) NOT NULL, 
    privs               INTEGER DEFAULT 0, 
    modsaccepted        INTEGER DEFAULT 0,
    modsrejected        INTEGER DEFAULT 0, 
    email               VARCHAR(64) DEFAULT NULL, 
    weburl              VARCHAR(255) DEFAULT NULL, 
    bio                 TEXT DEFAULT NULL,
    membersince         TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    emailconfirmdate    TIMESTAMP WITH TIME ZONE,
    lastlogindate       TIMESTAMP WITH TIME ZONE,
    automodsaccepted    INTEGER DEFAULT 0,
    modsfailed          INTEGER DEFAULT 0
);

CREATE TABLE moderator_preference
(
    id                  SERIAL,
    moderator           INTEGER NOT NULL, -- references moderator
    name                VARCHAR(50) NOT NULL,
    value               VARCHAR(100) NOT NULL
);

CREATE TABLE moderator_subscribe_artist
(
    id                  SERIAL,
    moderator           INTEGER NOT NULL, -- references moderator
    artist              INTEGER NOT NULL, -- weakly references artist
    lastmodsent         INTEGER NOT NULL, -- weakly references moderation
    deletedbymod        INTEGER NOT NULL DEFAULT 0, -- weakly references moderation
    mergedbymod         INTEGER NOT NULL DEFAULT 0 -- weakly references moderation
);

CREATE TABLE moderator_subscribe_label
(
    id                  SERIAL,
    moderator           INTEGER NOT NULL, -- references moderator
    label               INTEGER NOT NULL, -- weakly references label
    lastmodsent         INTEGER NOT NULL, -- weakly references moderation
    deletedbymod        INTEGER NOT NULL DEFAULT 0, -- weakly references moderation
    mergedbymod         INTEGER NOT NULL DEFAULT 0 -- weakly references moderation
);

CREATE TABLE editor_subscribe_editor
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references moderator (the one who has subscribed)
    subscribededitor    INTEGER NOT NULL, -- references moderator (the one being subscribed)
    lasteditsent        INTEGER NOT NULL  -- weakly references moderation
);

CREATE TABLE "Pending"
(
    "SeqId"             SERIAL,
    "TableName"         VARCHAR NOT NULL,
    "Op"                CHARACTER,
    "XID"               INT4 NOT NULL
);

CREATE TABLE "PendingData"
(
    "SeqId"             INT4 NOT NULL,
    "IsKey"             BOOL NOT NULL,
    "Data"              VARCHAR
);

CREATE TABLE puid
(
    id                  SERIAL,
    puid                CHAR(36) NOT NULL,
    lookupcount         INTEGER NOT NULL DEFAULT 0, -- updated via trigger
    version             INTEGER NOT NULL -- references clientversion
);

CREATE TABLE puid_stat
(
    id                  SERIAL,
    puid_id             INTEGER NOT NULL, -- references puid
    month_id            INTEGER NOT NULL,
    lookupcount         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE puidjoin
(
    id                  SERIAL,
    puid                INTEGER NOT NULL, -- references puid
    track               INTEGER NOT NULL, -- references track
    usecount            INTEGER DEFAULT 0 -- updated via trigger
);

CREATE TABLE puidjoin_stat
(
    id                  SERIAL,
    puidjoin_id         INTEGER NOT NULL, -- references puidjoin
    month_id            INTEGER NOT NULL,
    usecount            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE release
(
    id                  SERIAL,
    album               INTEGER NOT NULL, -- references album
    country             INTEGER NOT NULL, -- references country
    releasedate         CHAR(10) NOT NULL,
    modpending          INTEGER DEFAULT 0,
    label               INTEGER,          -- references label
    catno               VARCHAR(255),
    barcode             VARCHAR(255),
    format              SMALLINT
);

CREATE TABLE release_tag
(
    release             INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    count               INTEGER NOT NULL
);

CREATE TABLE replication_control
(
    id                              SERIAL,
    current_schema_sequence         INTEGER NOT NULL,
    current_replication_sequence    INTEGER,
    last_replication_date           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE script
(
     id                 SERIAL,
     isocode            CHAR(4) NOT NULL, -- ISO 15924
     isonumber          CHAR(3) NOT NULL, -- ISO 15924
     name               VARCHAR(100) NOT NULL,
     french_name        VARCHAR(100) NOT NULL,
     frequency          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE script_language
(
     id                 SERIAL,
     script		        INTEGER,
     language           INTEGER NOT NULL,
     frequency          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE stats
(
    id                  SERIAL,
    artists             INTEGER NOT NULL, 
    albums              INTEGER NOT NULL, 
    tracks              INTEGER NOT NULL, 
    discids             INTEGER NOT NULL, 
    moderations         INTEGER NOT NULL, 
    votes               INTEGER NOT NULL, 
    moderators          INTEGER NOT NULL, 
    timestamp           DATE NOT NULL
);

CREATE TABLE tag
(
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    refcount            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE tag_relation
(
    tag1                INTEGER NOT NULL, -- references tag
    tag2                INTEGER NOT NULL, -- references tag
    weight              INTEGER NOT NULL,
    CHECK (tag1 < tag2)
);

CREATE TABLE track
(
    id                  SERIAL,
    artist              INTEGER NOT NULL, -- references artist
    name                TEXT NOT NULL,
    gid                 CHAR(36) NOT NULL, 
    length              INTEGER DEFAULT 0,
    year                INTEGER DEFAULT 0,
    modpending          INTEGER DEFAULT 0
);

CREATE TABLE track_meta
(
    id                  INTEGER NOT NULL,
    rating              REAL,
    rating_count        INTEGER
);

CREATE TABLE track_tag
(
    track               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    count               INTEGER NOT NULL
);

CREATE TABLE trackwords
(
    wordid              INTEGER NOT NULL,
    trackid             INTEGER NOT NULL
);

CREATE TABLE url
(
    id                  SERIAL,
    gid                 CHAR(36) NOT NULL,
    url                 VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    refcount            INTEGER NOT NULL DEFAULT 0,
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE vote_closed
(
    id                  INTEGER NOT NULL,
    moderator           INTEGER NOT NULL, -- references moderator
    moderation          INTEGER NOT NULL, -- references moderation
    vote                SMALLINT NOT NULL,
    votetime            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    superseded          BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE vote_open
(
    id                  SERIAL NOT NULL,
    moderator           INTEGER NOT NULL, -- references moderator
    moderation          INTEGER NOT NULL, -- references moderation
    vote                SMALLINT NOT NULL,
    votetime            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    superseded          BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE wordlist
(
    id                  SERIAL,
    word                VARCHAR(255) NOT NULL,
    artistusecount      SMALLINT NOT NULL DEFAULT 0,
    albumusecount       SMALLINT NOT NULL DEFAULT 0,
    trackusecount       SMALLINT NOT NULL DEFAULT 0,
    labelusecount       SMALLINT NOT NULL DEFAULT 0
);

COMMIT;

-- vi: set ts=4 sw=4 et :
