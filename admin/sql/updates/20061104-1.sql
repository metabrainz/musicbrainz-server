-- Abstract: Labels & catalog numbers
--           Part 1: Tables, primary keys, indexes

\set ON_ERROR_STOP 1

BEGIN;

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

CREATE TABLE labelwords
(
    wordid              INTEGER NOT NULL,
    labelid            INTEGER NOT NULL
);

CREATE TABLE l_album_label
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references album
    link1               INTEGER NOT NULL DEFAULT 0, -- references label
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_album_label
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_label
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references artist
    link1               INTEGER NOT NULL DEFAULT 0, -- references label
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_artist_label
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_label
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references label
    link1               INTEGER NOT NULL DEFAULT 0, -- references label
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_label_label
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_track
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references label
    link1               INTEGER NOT NULL DEFAULT 0, -- references track
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_label_track
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_url
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references label
    link1               INTEGER NOT NULL DEFAULT 0, -- references url
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_label_url
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
);


insert into Label (Name, SortName, GID, ModPending, Page) 
      values ('Deleted Label', 'Deleted Label', 'f43e252d-9ebf-4e8e-bba8-36d080756cc1', 0, 0); 


ALTER TABLE release ADD label INTEGER;
ALTER TABLE release ADD catno VARCHAR(255);
ALTER TABLE release ADD barcode VARCHAR(255);
ALTER TABLE release ADD format SMALLINT;

ALTER TABLE wordlist ADD labelusecount SMALLINT NOT NULL DEFAULT 0;


ALTER TABLE label ADD CONSTRAINT label_pkey PRIMARY KEY (id);
ALTER TABLE labelwords ADD CONSTRAINT labelwords_pkey PRIMARY KEY (wordid, labelid);

ALTER TABLE l_album_label ADD CONSTRAINT l_album_label_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_label ADD CONSTRAINT l_artist_label_pkey PRIMARY KEY (id);
ALTER TABLE l_label_label ADD CONSTRAINT l_label_label_pkey PRIMARY KEY (id);
ALTER TABLE l_label_track ADD CONSTRAINT l_label_track_pkey PRIMARY KEY (id);
ALTER TABLE l_label_url ADD CONSTRAINT l_label_url_pkey PRIMARY KEY (id);

ALTER TABLE lt_album_label ADD CONSTRAINT lt_album_label_pkey PRIMARY KEY (id);
ALTER TABLE lt_artist_label ADD CONSTRAINT lt_artist_label_pkey PRIMARY KEY (id);
ALTER TABLE lt_label_label ADD CONSTRAINT lt_label_label_pkey PRIMARY KEY (id);
ALTER TABLE lt_label_track ADD CONSTRAINT lt_label_track_pkey PRIMARY KEY (id);
ALTER TABLE lt_label_url ADD CONSTRAINT lt_label_url_pkey PRIMARY KEY (id);


CREATE UNIQUE INDEX label_gidindex ON label (gid);
CREATE INDEX label_nameindex ON label (name);
CREATE INDEX label_pageindex ON label (page);
CREATE INDEX labelwords_labelidindex ON labelwords (labelid);
CREATE INDEX release_label ON release (label);

CREATE UNIQUE INDEX l_album_label_idx_uniq ON l_album_label (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_artist_label_idx_uniq ON l_artist_label (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_label_label_idx_uniq ON l_label_label (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_label_track_idx_uniq ON l_label_track (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_label_url_idx_uniq ON l_label_url (link0, link1, link_type, begindate, enddate);

CREATE UNIQUE INDEX lt_album_label_idx_mbid ON lt_album_label (mbid);
CREATE UNIQUE INDEX lt_album_label_idx_parent_name ON lt_album_label (parent, name);
CREATE UNIQUE INDEX lt_artist_label_idx_mbid ON lt_artist_label (mbid);
CREATE UNIQUE INDEX lt_artist_label_idx_parent_name ON lt_artist_label (parent, name);
CREATE UNIQUE INDEX lt_label_label_idx_mbid ON lt_label_label (mbid);
CREATE UNIQUE INDEX lt_label_label_idx_parent_name ON lt_label_label (parent, name);
CREATE UNIQUE INDEX lt_label_track_idx_mbid ON lt_label_track (mbid);
CREATE UNIQUE INDEX lt_label_track_idx_parent_name ON lt_label_track (parent, name);
CREATE UNIQUE INDEX lt_label_url_idx_mbid ON lt_label_url (mbid);
CREATE UNIQUE INDEX lt_label_url_idx_parent_name ON lt_label_url (parent, name);

CREATE TABLE labelalias
(
    id                  SERIAL,
    ref                 INTEGER NOT NULL, -- references label
    name                VARCHAR(255) NOT NULL, 
    timesused           INTEGER DEFAULT 0,
    modpending          INTEGER DEFAULT 0,
    lastused            TIMESTAMP WITH TIME ZONE
);
ALTER TABLE labelalias ADD CONSTRAINT labelalias_pkey PRIMARY KEY (id);
CREATE INDEX labelalias_nameindex ON labelalias (name);
CREATE INDEX labelalias_refindex ON labelalias (ref);


CREATE TABLE moderator_subscribe_label
(
    id                  SERIAL,
    moderator           INTEGER NOT NULL, -- references moderator
    label               INTEGER NOT NULL, -- weakly references label
    lastmodsent         INTEGER NOT NULL, -- weakly references moderation
    deletedbymod        INTEGER NOT NULL DEFAULT 0, -- weakly references moderation
    mergedbymod         INTEGER NOT NULL DEFAULT 0 -- weakly references moderation
);

ALTER TABLE moderator_subscribe_label ADD CONSTRAINT moderator_subscribe_label_pkey PRIMARY KEY (id);
CREATE UNIQUE INDEX moderator_subscribe_label_moderator_key ON moderator_subscribe_label (moderator, label);

-- Add table gid_redirect

CREATE TABLE gid_redirect
(
    gid                 CHAR(36) NOT NULL,
    newid               INTEGER NOT NULL,
    tbl                 SMALLINT NOT NULL
);

ALTER TABLE gid_redirect ADD CONSTRAINT gid_redirect_pkey PRIMARY KEY (gid);
CREATE INDEX gid_redirect_newid ON gid_redirect (newid);

-- Add the quality columns to the artist and album tables

ALTER TABLE artist ADD COLUMN quality SMALLINT DEFAULT -1; 
ALTER TABLE artist ADD COLUMN modpending_qual INTEGER DEFAULT 0; 
ALTER TABLE album ADD COLUMN quality SMALLINT DEFAULT -1; 
ALTER TABLE album ADD COLUMN modpending_qual INTEGER DEFAULT 0; 

COMMIT;

-- vi: set ts=4 sw=4 et :
