-- Abstract: Create the AR tables: url, link_attribute_type, l_* and lt_*

\set ON_ERROR_STOP 1

BEGIN;

-- General changes
DROP INDEX artist_nameindex;
CREATE INDEX artist_nameindex ON artist (name);

-- AR related changes
ALTER TABLE artist ADD COLUMN resolution VARCHAR(64);
ALTER TABLE artist ADD COLUMN begindate CHAR(10);
ALTER TABLE artist ADD COLUMN enddate CHAR(10);
ALTER TABLE artist ADD COLUMN type SMALLINT;

-- These is the link attribute table for things like instruments and vocals
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

CREATE TABLE link_attribute
(
    id                  SERIAL,
    attribute_type      INTEGER NOT NULL DEFAULT 0, -- references link_attribute_type
    link                INTEGER NOT NULL DEFAULT 0, -- references l_<ent>_<ent> without FK
    link_type           VARCHAR(32) NOT NULL DEFAULT '' -- indicates which l_ table to refer to
);

-- The entities we're going to be linking are: album artist track url

CREATE TABLE url
(
    id                  SERIAL,
    gid                 CHAR(36) NOT NULL,
    url                 VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    refcount            INTEGER NOT NULL DEFAULT 0,
    modpending          INTEGER NOT NULL DEFAULT 0
);

-- Each pair of entitity types gets a link type table
-- Default data is created by MusicBrainz::Server::LinkType

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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
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
    modpending          INTEGER NOT NULL DEFAULT 0
);

-- Each pair of entitity types gets a link table

CREATE TABLE l_album_album
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references album
    link1               INTEGER NOT NULL DEFAULT 0, -- references album
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_album_album
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_album_artist
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references album
    link1               INTEGER NOT NULL DEFAULT 0, -- references artist
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_album_artist
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_album_track
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references album
    link1               INTEGER NOT NULL DEFAULT 0, -- references track
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_album_track
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_album_url
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references album
    link1               INTEGER NOT NULL DEFAULT 0, -- references url
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_album_url
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_artist
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references artist
    link1               INTEGER NOT NULL DEFAULT 0, -- references artist
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_artist_artist
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_track
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references artist
    link1               INTEGER NOT NULL DEFAULT 0, -- references track
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_artist_track
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_url
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references artist
    link1               INTEGER NOT NULL DEFAULT 0, -- references url
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_artist_url
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_track_track
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references track
    link1               INTEGER NOT NULL DEFAULT 0, -- references track
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_track_track
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_track_url
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references track
    link1               INTEGER NOT NULL DEFAULT 0, -- references url
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_track_url
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_url_url
(
    id                  SERIAL,
    link0               INTEGER NOT NULL DEFAULT 0, -- references track
    link1               INTEGER NOT NULL DEFAULT 0, -- references url
    link_type           INTEGER NOT NULL DEFAULT 0, -- references lt_track_url
    begindate           CHAR(10) NOT NULL DEFAULT '',
    enddate             CHAR(10) NOT NULL DEFAULT '',
    modpending          INTEGER NOT NULL DEFAULT 0
);


ALTER TABLE l_album_album ADD CONSTRAINT l_album_album_pkey PRIMARY KEY (id);
ALTER TABLE l_album_artist ADD CONSTRAINT l_album_artist_pkey PRIMARY KEY (id);
ALTER TABLE l_album_track ADD CONSTRAINT l_album_track_pkey PRIMARY KEY (id);
ALTER TABLE l_album_url ADD CONSTRAINT l_album_url_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_artist ADD CONSTRAINT l_artist_artist_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_track ADD CONSTRAINT l_artist_track_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_url ADD CONSTRAINT l_artist_url_pkey PRIMARY KEY (id);
ALTER TABLE l_track_track ADD CONSTRAINT l_track_track_pkey PRIMARY KEY (id);
ALTER TABLE l_track_url ADD CONSTRAINT l_track_url_pkey PRIMARY KEY (id);
ALTER TABLE l_url_url ADD CONSTRAINT l_url_url_pkey PRIMARY KEY (id);
ALTER TABLE link_attribute ADD CONSTRAINT link_attribute_pkey PRIMARY KEY (id);
ALTER TABLE link_attribute_type ADD CONSTRAINT link_attribute_type_pkey PRIMARY KEY (id);
ALTER TABLE lt_album_album ADD CONSTRAINT lt_album_album_pkey PRIMARY KEY (id);
ALTER TABLE lt_album_artist ADD CONSTRAINT lt_album_artist_pkey PRIMARY KEY (id);
ALTER TABLE lt_album_track ADD CONSTRAINT lt_album_track_pkey PRIMARY KEY (id);
ALTER TABLE lt_album_url ADD CONSTRAINT lt_album_url_pkey PRIMARY KEY (id);
ALTER TABLE lt_artist_artist ADD CONSTRAINT lt_artist_artist_pkey PRIMARY KEY (id);
ALTER TABLE lt_artist_track ADD CONSTRAINT lt_artist_track_pkey PRIMARY KEY (id);
ALTER TABLE lt_artist_url ADD CONSTRAINT lt_artist_url_pkey PRIMARY KEY (id);
ALTER TABLE lt_track_track ADD CONSTRAINT lt_track_track_pkey PRIMARY KEY (id);
ALTER TABLE lt_track_url ADD CONSTRAINT lt_track_url_pkey PRIMARY KEY (id);
ALTER TABLE lt_url_url ADD CONSTRAINT lt_url_url_pkey PRIMARY KEY (id);
ALTER TABLE url ADD CONSTRAINT url_pkey PRIMARY KEY (id);

CREATE UNIQUE INDEX l_album_album_idx_uniq ON l_album_album (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_album_artist_idx_uniq ON l_album_artist (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_album_track_idx_uniq ON l_album_track (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_album_url_idx_uniq ON l_album_url (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_artist_artist_idx_uniq ON l_artist_artist (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_artist_track_idx_uniq ON l_artist_track (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_artist_url_idx_uniq ON l_artist_url (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_track_track_idx_uniq ON l_track_track (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_track_url_idx_uniq ON l_track_url (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_url_url_idx_uniq ON l_url_url (link0, link1, link_type, begindate, enddate);

CREATE INDEX link_attribute_idx_link_type ON link_attribute (link, link_type);
CREATE UNIQUE INDEX link_attribute_type_idx_parent_name ON link_attribute_type (parent, name);
CREATE INDEX link_attribute_type_idx_name ON link_attribute_type (name);

CREATE UNIQUE INDEX lt_album_album_idx_mbid ON lt_album_album (mbid);
CREATE UNIQUE INDEX lt_album_album_idx_parent_name ON lt_album_album (parent, name);
CREATE UNIQUE INDEX lt_album_artist_idx_mbid ON lt_album_artist (mbid);
CREATE UNIQUE INDEX lt_album_artist_idx_parent_name ON lt_album_artist (parent, name);
CREATE UNIQUE INDEX lt_album_track_idx_mbid ON lt_album_track (mbid);
CREATE UNIQUE INDEX lt_album_track_idx_parent_name ON lt_album_track (parent, name);
CREATE UNIQUE INDEX lt_album_url_idx_mbid ON lt_album_url (mbid);
CREATE UNIQUE INDEX lt_album_url_idx_parent_name ON lt_album_url (parent, name);
CREATE UNIQUE INDEX lt_artist_artist_idx_mbid ON lt_artist_artist (mbid);
CREATE UNIQUE INDEX lt_artist_artist_idx_parent_name ON lt_artist_artist (parent, name);
CREATE UNIQUE INDEX lt_artist_track_idx_mbid ON lt_artist_track (mbid);
CREATE UNIQUE INDEX lt_artist_track_idx_parent_name ON lt_artist_track (parent, name);
CREATE UNIQUE INDEX lt_artist_url_idx_mbid ON lt_artist_url (mbid);
CREATE UNIQUE INDEX lt_artist_url_idx_parent_name ON lt_artist_url (parent, name);
CREATE UNIQUE INDEX lt_track_track_idx_mbid ON lt_track_track (mbid);
CREATE UNIQUE INDEX lt_track_track_idx_parent_name ON lt_track_track (parent, name);
CREATE UNIQUE INDEX lt_track_url_idx_mbid ON lt_track_url (mbid);
CREATE UNIQUE INDEX lt_track_url_idx_parent_name ON lt_track_url (parent, name);
CREATE UNIQUE INDEX lt_url_url_idx_mbid ON lt_url_url (mbid);
CREATE UNIQUE INDEX lt_url_url_idx_parent_name ON lt_url_url (parent, name);
CREATE UNIQUE INDEX url_idx_gid ON url (gid);

ALTER TABLE link_attribute
    ADD CONSTRAINT fk_link_attribute_type_id
    FOREIGN KEY (attribute_type)
    REFERENCES link_attribute_type(id);

ALTER TABLE lt_album_album
    ADD CONSTRAINT fk_lt_album_album_parent
    FOREIGN KEY (parent)
    REFERENCES lt_album_album(id);
ALTER TABLE l_album_album
    ADD CONSTRAINT fk_l_album_album_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_album_album(id);
ALTER TABLE l_album_album
    ADD CONSTRAINT fk_l_album_album_link0
    FOREIGN KEY (link0)
    REFERENCES album(id);
ALTER TABLE l_album_album
    ADD CONSTRAINT fk_l_album_album_link1
    FOREIGN KEY (link1)
    REFERENCES album(id);

ALTER TABLE lt_album_artist
    ADD CONSTRAINT fk_lt_album_artist_parent
    FOREIGN KEY (parent)
    REFERENCES lt_album_artist(id);
ALTER TABLE l_album_artist
    ADD CONSTRAINT fk_l_album_artist_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_album_artist(id);
ALTER TABLE l_album_artist
    ADD CONSTRAINT fk_l_album_artist_link0
    FOREIGN KEY (link0)
    REFERENCES album(id);
ALTER TABLE l_album_artist
    ADD CONSTRAINT fk_l_album_artist_link1
    FOREIGN KEY (link1)
    REFERENCES artist(id);

ALTER TABLE lt_album_track
    ADD CONSTRAINT fk_lt_album_track_parent
    FOREIGN KEY (parent)
    REFERENCES lt_album_track(id);
ALTER TABLE l_album_track
    ADD CONSTRAINT fk_l_album_track_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_album_track(id);
ALTER TABLE l_album_track
    ADD CONSTRAINT fk_l_album_track_link0
    FOREIGN KEY (link0)
    REFERENCES album(id);
ALTER TABLE l_album_track
    ADD CONSTRAINT fk_l_album_track_link1
    FOREIGN KEY (link1)
    REFERENCES track(id);

ALTER TABLE lt_album_url
    ADD CONSTRAINT fk_lt_album_url_parent
    FOREIGN KEY (parent)
    REFERENCES lt_album_url(id);
ALTER TABLE l_album_url
    ADD CONSTRAINT fk_l_album_url_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_album_url(id);
ALTER TABLE l_album_url
    ADD CONSTRAINT fk_l_album_url_link0
    FOREIGN KEY (link0)
    REFERENCES album(id);
ALTER TABLE l_album_url
    ADD CONSTRAINT fk_l_album_url_link1
    FOREIGN KEY (link1)
    REFERENCES url(id);

ALTER TABLE lt_artist_artist
    ADD CONSTRAINT fk_lt_artist_artist_parent
    FOREIGN KEY (parent)
    REFERENCES lt_artist_artist(id);
ALTER TABLE l_artist_artist
    ADD CONSTRAINT fk_l_artist_artist_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_artist_artist(id);
ALTER TABLE l_artist_artist
    ADD CONSTRAINT fk_l_artist_artist_link0
    FOREIGN KEY (link0)
    REFERENCES artist(id);
ALTER TABLE l_artist_artist
    ADD CONSTRAINT fk_l_artist_artist_link1
    FOREIGN KEY (link1)
    REFERENCES artist(id);

ALTER TABLE lt_artist_track
    ADD CONSTRAINT fk_lt_artist_track_parent
    FOREIGN KEY (parent)
    REFERENCES lt_artist_track(id);
ALTER TABLE l_artist_track
    ADD CONSTRAINT fk_l_artist_track_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_artist_track(id);
ALTER TABLE l_artist_track
    ADD CONSTRAINT fk_l_artist_track_link0
    FOREIGN KEY (link0)
    REFERENCES artist(id);
ALTER TABLE l_artist_track
    ADD CONSTRAINT fk_l_artist_track_link1
    FOREIGN KEY (link1)
    REFERENCES track(id);

ALTER TABLE lt_artist_url
    ADD CONSTRAINT fk_lt_artist_url_parent
    FOREIGN KEY (parent)
    REFERENCES lt_artist_url(id);
ALTER TABLE l_artist_url
    ADD CONSTRAINT fk_l_artist_url_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_artist_url(id);
ALTER TABLE l_artist_url
    ADD CONSTRAINT fk_l_artist_url_link0
    FOREIGN KEY (link0)
    REFERENCES artist(id);
ALTER TABLE l_artist_url
    ADD CONSTRAINT fk_l_artist_url_link1
    FOREIGN KEY (link1)
    REFERENCES url(id);

ALTER TABLE lt_track_track
    ADD CONSTRAINT fk_lt_track_track_parent
    FOREIGN KEY (parent)
    REFERENCES lt_track_track(id);
ALTER TABLE l_track_track
    ADD CONSTRAINT fk_l_track_track_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_track_track(id);
ALTER TABLE l_track_track
    ADD CONSTRAINT fk_l_track_track_link0
    FOREIGN KEY (link0)
    REFERENCES track(id);
ALTER TABLE l_track_track
    ADD CONSTRAINT fk_l_track_track_link1
    FOREIGN KEY (link1)
    REFERENCES track(id);

ALTER TABLE lt_track_url
    ADD CONSTRAINT fk_lt_track_url_parent
    FOREIGN KEY (parent)
    REFERENCES lt_track_url(id);
ALTER TABLE l_track_url
    ADD CONSTRAINT fk_l_track_url_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_track_url(id);
ALTER TABLE l_track_url
    ADD CONSTRAINT fk_l_track_url_link0
    FOREIGN KEY (link0)
    REFERENCES track(id);
ALTER TABLE l_track_url
    ADD CONSTRAINT fk_l_track_url_link1
    FOREIGN KEY (link1)
    REFERENCES url(id);

ALTER TABLE lt_url_url
    ADD CONSTRAINT fk_lt_url_url_parent
    FOREIGN KEY (parent)
    REFERENCES lt_url_url(id);
ALTER TABLE l_url_url
    ADD CONSTRAINT fk_l_url_url_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_url_url(id);
ALTER TABLE l_url_url
    ADD CONSTRAINT fk_l_url_url_link0
    FOREIGN KEY (link0)
    REFERENCES url(id);
ALTER TABLE l_url_url
    ADD CONSTRAINT fk_l_url_url_link1
    FOREIGN KEY (link1)
    REFERENCES url(id);

COMMIT;

-- vi: set ts=4 sw=4 et tw=0 :
