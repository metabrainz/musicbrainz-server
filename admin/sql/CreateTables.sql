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
    page                INTEGER NOT NULL
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
    Id                  INTEGER NOT NULL,
    tracks              INTEGER DEFAULT 0,
    discids             INTEGER DEFAULT 0,
    trmids              INTEGER DEFAULT 0,
    firstreleasedate    CHAR(10),
    asin                CHAR(10),
    coverarturl         VARCHAR(255)
);

CREATE TABLE albumwords
(
    wordid              INTEGER NOT NULL,
    albumid             INTEGER NOT NULL
);

CREATE TABLE artist
(
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    gid                 CHAR(36) NOT NULL,
    modpending          INTEGER DEFAULT 0,
    sortname            VARCHAR(255) NOT NULL,
    page                INTEGER NOT NULL
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

CREATE TABLE artistwords
(
    wordid              INTEGER NOT NULL,
    artistid            INTEGER NOT NULL
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
    trackoffset         INTEGER[] NOT NULL
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

CREATE TABLE moderation_note_closed
(
    id                  INTEGER NOT NULL,
    moderation          INTEGER NOT NULL, 
    moderator           INTEGER NOT NULL, 
    text                TEXT NOT NULL
);

CREATE TABLE moderation_note_open
(
    id                  SERIAL NOT NULL,
    moderation          INTEGER NOT NULL, 
    moderator           INTEGER NOT NULL, 
    text                TEXT NOT NULL
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
    prevvalue           VARCHAR(255) NOT NULL, 
    newvalue            TEXT NOT NULL, 
    yesvotes            INTEGER DEFAULT 0, 
    novotes             INTEGER DEFAULT 0,
    depmod              INTEGER DEFAULT 0,
    automod             SMALLINT DEFAULT 0,
    opentime            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    closetime           TIMESTAMP WITH TIME ZONE,
    expiretime          TIMESTAMP WITH TIME ZONE NOT NULL
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
    prevvalue           VARCHAR(255) NOT NULL, 
    newvalue            TEXT NOT NULL, 
    yesvotes            INTEGER DEFAULT 0, 
    novotes             INTEGER DEFAULT 0,
    depmod              INTEGER DEFAULT 0,
    automod             SMALLINT DEFAULT 0,
    opentime            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    closetime           TIMESTAMP WITH TIME ZONE,
    expiretime          TIMESTAMP WITH TIME ZONE NOT NULL
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

CREATE TABLE release
(
    id                  SERIAL,
    album               INTEGER NOT NULL, -- references album
    country             INTEGER NOT NULL, -- references country
    releasedate         CHAR(10) NOT NULL,
    modpending          INTEGER DEFAULT 0
);

CREATE TABLE replication_control
(
    id                              SERIAL,
    current_schema_sequence         INTEGER NOT NULL,
    current_replication_sequence    INTEGER,
    last_replication_date           TIMESTAMP WITH TIME ZONE
);

CREATE TABLE stats
(
    id                  SERIAL,
    artists             INTEGER NOT NULL, 
    albums              INTEGER NOT NULL, 
    tracks              INTEGER NOT NULL, 
    discids             INTEGER NOT NULL, 
    trmids              INTEGER NOT NULL, 
    moderations         INTEGER NOT NULL, 
    votes               INTEGER NOT NULL, 
    moderators          INTEGER NOT NULL, 
    timestamp           DATE NOT NULL
);

CREATE TABLE track
(
    id                  SERIAL,
    artist              INTEGER NOT NULL, -- references artist
    name                VARCHAR(255) NOT NULL,
    gid                 CHAR(36) NOT NULL, 
    length              INTEGER DEFAULT 0,
    year                INTEGER DEFAULT 0,
    modpending          INTEGER DEFAULT 0
);

CREATE TABLE trackwords
(
    wordid              INTEGER NOT NULL,
    trackid             INTEGER NOT NULL
);

CREATE TABLE trm
(
    id                  SERIAL,
    trm                 CHAR(36) NOT NULL,
    lookupcount         INTEGER DEFAULT 0,
    version             INTEGER NOT NULL -- references clientversion
);

CREATE TABLE trmjoin
(
    id                  SERIAL,
    trm                 INTEGER NOT NULL, -- references trm
    track               INTEGER NOT NULL -- references track
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
    trackusecount       SMALLINT NOT NULL DEFAULT 0
);

COMMIT;

-- vi: set ts=4 sw=4 et :
