\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE artist
(
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    gid                 CHAR(36) NOT NULL,
    modpending          INT DEFAULT 0,
    sortname            VARCHAR(255) NOT NULL,
    page                INT NOT NULL
);

CREATE TABLE artistalias
(
    id                  SERIAL,
    ref                 INT NOT NULL, -- references artist
    name                VARCHAR(255) NOT NULL, 
    timesused           INT DEFAULT 0,
    modpending          INT DEFAULT 0,
    lastused            TIMESTAMP WITH TIME ZONE
);

CREATE TABLE album
(
    id                  SERIAL,
    artist              INT NOT NULL, -- references artist
    name                VARCHAR(255) NOT NULL,
    gid                 CHAR(36) NOT NULL, 
    modpending          INT DEFAULT 0,
    attributes          INT[] DEFAULT '{0}',
    page                INT NOT NULL
);

CREATE TABLE albummeta
(
    Id                  INTEGER NOT NULL,
    tracks              INT DEFAULT 0,
    discids             INT DEFAULT 0,
    trmids              INT DEFAULT 0,
    firstreleasedate    CHAR(10),
    asin                CHAR(10),
    coverarturl         VARCHAR(255)
);

CREATE TABLE track
(
    id                  SERIAL,
    artist              INT NOT NULL, -- references artist
    name                VARCHAR(255) NOT NULL,
    gid                 CHAR(36) NOT NULL, 
    length              INT DEFAULT 0,
    year                INT DEFAULT 0,
    modpending          INT DEFAULT 0
);

CREATE TABLE albumjoin
(
    id                  SERIAL,
    album               INT NOT NULL, -- references album
    track               INT NOT NULL, -- references track
    sequence            INT NOT NULL,
    modpending          INT DEFAULT 0
);

CREATE TABLE clientversion
(
    id                  SERIAL,
    version             VARCHAR(64) NOT NULL
);

CREATE TABLE trm
(
    id                  SERIAL,
    trm                 CHAR(36) NOT NULL,
    lookupcount         INT DEFAULT 0,
    version             INT NOT NULL -- references clientversion
);

CREATE TABLE trmjoin
(
    id                  SERIAL,
    trm                 INT NOT NULL, -- references trm
    track               INT NOT NULL -- references track
);

CREATE TABLE discid
(
    id                  SERIAL,
    album               INT NOT NULL, -- references album
    disc                CHAR(28) NOT NULL,
    toc                 TEXT NOT NULL, 
    modpending          INT DEFAULT 0
);

CREATE TABLE toc
(
    id                  SERIAL,
    album               INT NOT NULL, -- references album
    discid              CHAR(28), -- references discid (disc)
    tracks              INT,
    leadout int, track1 int, track2 int, track3 int, track4 int, track5 int, track6 int, track7 int, 
    track8 int, track9 int, track10 int, track11 int, track12 int, track13 int, track14 int, 
    track15 int, track16 int, track17 int, track18 int, track19 int, track20 int, track21 int, 
    track22 int, track23 int, track24 int, track25 int, track26 int, track27 int, track28 int, 
    track29 int, track30 int, track31 int, track32 int, track33 int, track34 int, track35 int, 
    track36 int, track37 int, track38 int, track39 int, track40 int, track41 int, track42 int, 
    track43 int, track44 int, track45 int, track46 int, track47 int, track48 int, track49 int, 
    track50 int, track51 int, track52 int, track53 int, track54 int, track55 int, track56 int, 
    track57 int, track58 int, track59 int, track60 int, track61 int, track62 int, track63 int, 
    track64 int, track65 int, track66 int, track67 int, track68 int, track69 int, track70 int, 
    track71 int, track72 int, track73 int, track74 int, track75 int, track76 int, track77 int, 
    track78 int, track79 int, track80 int, track81 int, track82 int, track83 int, track84 int, 
    track85 int, track86 int, track87 int, track88 int, track89 int, track90 int, track91 int, 
    track92 int, track93 int, track94 int, track95 int, track96 int, track97 int, track98 int, 
    track99 int
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

CREATE TABLE moderation_open
(
    id                  SERIAL NOT NULL,
    artist              INT NOT NULL, -- references artist
    moderator           INT NOT NULL, -- references moderator
    tab                 VARCHAR(32) NOT NULL,
    col                 VARCHAR(64) NOT NULL, 
    type                SMALLINT NOT NULL, 
    status              SMALLINT NOT NULL, 
    rowid               INT NOT NULL, 
    prevvalue           VARCHAR(255) NOT NULL, 
    newvalue            TEXT NOT NULL, 
    yesvotes            INT DEFAULT 0, 
    novotes             INT DEFAULT 0,
    depmod              INT DEFAULT 0,
    automod             SMALLINT DEFAULT 0,
    opentime            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    closetime           TIMESTAMP WITH TIME ZONE,
    expiretime          TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE moderation_note_open
(
    id                  SERIAL NOT NULL,
    moderation          INT NOT NULL, 
    moderator           INT NOT NULL, 
    text                TEXT NOT NULL
);

CREATE TABLE vote_open
(
    id                  SERIAL NOT NULL,
    moderator           INT NOT NULL, -- references moderator
    moderation          INT NOT NULL, -- references moderation
    vote                SMALLINT NOT NULL,
    votetime            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    superseded          BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE moderation_closed
(
    id                  INT NOT NULL,
    artist              INT NOT NULL, -- references artist
    moderator           INT NOT NULL, -- references moderator
    tab                 VARCHAR(32) NOT NULL,
    col                 VARCHAR(64) NOT NULL, 
    type                SMALLINT NOT NULL, 
    status              SMALLINT NOT NULL, 
    rowid               INT NOT NULL, 
    prevvalue           VARCHAR(255) NOT NULL, 
    newvalue            TEXT NOT NULL, 
    yesvotes            INT DEFAULT 0, 
    novotes             INT DEFAULT 0,
    depmod              INT DEFAULT 0,
    automod             SMALLINT DEFAULT 0,
    opentime            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    closetime           TIMESTAMP WITH TIME ZONE,
    expiretime          TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE moderation_note_closed
(
    id                  INT NOT NULL,
    moderation          INT NOT NULL, 
    moderator           INT NOT NULL, 
    text                TEXT NOT NULL
);

CREATE TABLE vote_closed
(
    id                  INT NOT NULL,
    moderator           INT NOT NULL, -- references moderator
    moderation          INT NOT NULL, -- references moderation
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

CREATE TABLE artistwords
(
    wordid              INT NOT NULL,
    artistid            INT NOT NULL
);

CREATE TABLE albumwords
(
    wordid              INT NOT NULL,
    albumid             INT NOT NULL
);

CREATE TABLE trackwords
(
    wordid              INT NOT NULL,
    trackid             INT NOT NULL
);

CREATE TABLE stats
(
    id                  SERIAL,
    artists             INT NOT NULL, 
    albums              INT NOT NULL, 
    tracks              INT NOT NULL, 
    discids             INT NOT NULL, 
    trmids              INT NOT NULL, 
    moderations         INT NOT NULL, 
    votes               INT NOT NULL, 
    moderators          INT NOT NULL, 
    timestamp           DATE NOT NULL
);

CREATE TABLE artist_relation
(
    id                  SERIAL,
    artist              INT NOT NULL, -- references artist
    ref                 INT NOT NULL, -- references artist
    weight              INTEGER NOT NULL
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

CREATE TABLE country
(
    id                  SERIAL,
    isocode             VARCHAR(2) NOT NULL,
    name                VARCHAR(100) NOT NULL
);

CREATE TABLE release
(
    id                  SERIAL,
    album               INTEGER NOT NULL, -- references album
    country             INTEGER NOT NULL, -- references country
    releasedate         CHAR(10) NOT NULL,
    modpending          INTEGER DEFAULT 0
);

CREATE TABLE album_amazon_asin
(
    album               INTEGER NOT NULL, -- references album
    asin                CHAR(10),
    coverarturl         VARCHAR(255),
    lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE replication_control
(
    id                              SERIAL,
    current_schema_sequence         INTEGER NOT NULL,
    current_replication_sequence    INTEGER,
    last_replication_date           TIMESTAMP WITH TIME ZONE
);

COMMIT;

-- vi: set ts=4 sw=4 et :
