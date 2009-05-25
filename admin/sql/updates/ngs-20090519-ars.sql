BEGIN;

CREATE TABLE l_artist_artist
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references artist.id
    entity1         INTEGER NOT NULL, -- references artist.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_label
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references artist.id
    entity1         INTEGER NOT NULL, -- references label.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_recording
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references artist.id
    entity1         INTEGER NOT NULL, -- references recording.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_release
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references artist.id
    entity1         INTEGER NOT NULL, -- references release.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_release_group
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references artist.id
    entity1         INTEGER NOT NULL, -- references release_group.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_url
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references artist.id
    entity1         INTEGER NOT NULL, -- references url.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_artist_work
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references artist.id
    entity1         INTEGER NOT NULL, -- references work.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_label
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references label.id
    entity1         INTEGER NOT NULL, -- references label.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_recording
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references label.id
    entity1         INTEGER NOT NULL, -- references recording.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_release
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references label.id
    entity1         INTEGER NOT NULL, -- references release.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_release_group
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references label.id
    entity1         INTEGER NOT NULL, -- references release_group.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_url
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references label.id
    entity1         INTEGER NOT NULL, -- references url.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_label_work
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references label.id
    entity1         INTEGER NOT NULL, -- references work.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_recording_recording
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references recording.id
    entity1         INTEGER NOT NULL, -- references recording.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_recording_release
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references recording.id
    entity1         INTEGER NOT NULL, -- references release.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_recording_release_group
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references recording.id
    entity1         INTEGER NOT NULL, -- references release_group.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_recording_url
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references recording.id
    entity1         INTEGER NOT NULL, -- references url.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_recording_work
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references recording.id
    entity1         INTEGER NOT NULL, -- references work.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_release
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references release.id
    entity1         INTEGER NOT NULL, -- references release.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_release_group
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references release.id
    entity1         INTEGER NOT NULL, -- references release_group.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_url
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references release.id
    entity1         INTEGER NOT NULL, -- references url.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_work
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references release.id
    entity1         INTEGER NOT NULL, -- references work.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_group_release_group
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references release_group.id
    entity1         INTEGER NOT NULL, -- references release_group.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_group_url
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references release_group.id
    entity1         INTEGER NOT NULL, -- references url.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_release_group_work
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references release_group.id
    entity1         INTEGER NOT NULL, -- references work.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_url_url
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references url.id
    entity1         INTEGER NOT NULL, -- references url.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_url_work
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references url.id
    entity1         INTEGER NOT NULL, -- references work.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE l_work_work
(
    id              SERIAL,
    link            INTEGER NOT NULL, -- references link.id
    entity0         INTEGER NOT NULL, -- references work.id
    entity1         INTEGER NOT NULL, -- references work.id
    editpending     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE link
(
    id              SERIAL,
    link_type       INTEGER NOT NULL, -- references link_type.id
    begindate_year  SMALLINT,
    begindate_month SMALLINT,
    begindate_day   SMALLINT,
    enddate_year    SMALLINT,
    enddate_month   SMALLINT,
    enddate_day     SMALLINT,
    attributecount  INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE link_attribute
(
    link            INTEGER NOT NULL, -- references link.id
    attribute_type  INTEGER NOT NULL -- references link_attribute_type.id
);

CREATE TABLE link_attribute_type
(
    id              SERIAL,
    parent          INTEGER, -- references link_attribute_type.id
    root            INTEGER NOT NULL, -- references link_attribute_type.id
    childorder      INTEGER NOT NULL DEFAULT 0,
    gid             UUID NOT NULL,
    name            VARCHAR(255) NOT NULL,
    description     TEXT
);

CREATE TABLE link_type
(
    id              SERIAL,
    parent          INTEGER, -- references link_type.id
    childorder      INTEGER NOT NULL DEFAULT 0,
    gid             UUID NOT NULL,
    entitytype0     VARCHAR(50),
    entitytype1     VARCHAR(50),
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    linkphrase      VARCHAR(255) NOT NULL,
    rlinkphrase     VARCHAR(255) NOT NULL,
    shortlinkphrase VARCHAR(255) NOT NULL,
    priority        INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE link_type_attribute_type
(
    link_type       INTEGER NOT NULL, -- references link_type.id
    attribute_type  INTEGER NOT NULL, -- references link_attribute_type.id
    min             SMALLINT,
    max             SMALLINT
);

ALTER TABLE l_artist_artist ADD CONSTRAINT l_artist_artist_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_label ADD CONSTRAINT l_artist_label_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_recording ADD CONSTRAINT l_artist_recording_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_release ADD CONSTRAINT l_artist_release_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_release_group ADD CONSTRAINT l_artist_release_group_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_url ADD CONSTRAINT l_artist_url_pkey PRIMARY KEY (id);
ALTER TABLE l_artist_work ADD CONSTRAINT l_artist_work_pkey PRIMARY KEY (id);
ALTER TABLE l_label_label ADD CONSTRAINT l_label_label_pkey PRIMARY KEY (id);
ALTER TABLE l_label_recording ADD CONSTRAINT l_label_recording_pkey PRIMARY KEY (id);
ALTER TABLE l_label_release ADD CONSTRAINT l_label_release_pkey PRIMARY KEY (id);
ALTER TABLE l_label_release_group ADD CONSTRAINT l_label_release_group_pkey PRIMARY KEY (id);
ALTER TABLE l_label_url ADD CONSTRAINT l_label_url_pkey PRIMARY KEY (id);
ALTER TABLE l_label_work ADD CONSTRAINT l_label_work_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_recording ADD CONSTRAINT l_recording_recording_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_release ADD CONSTRAINT l_recording_release_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_release_group ADD CONSTRAINT l_recording_release_group_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_url ADD CONSTRAINT l_recording_url_pkey PRIMARY KEY (id);
ALTER TABLE l_recording_work ADD CONSTRAINT l_recording_work_pkey PRIMARY KEY (id);
ALTER TABLE l_release_release ADD CONSTRAINT l_release_release_pkey PRIMARY KEY (id);
ALTER TABLE l_release_release_group ADD CONSTRAINT l_release_release_group_pkey PRIMARY KEY (id);
ALTER TABLE l_release_url ADD CONSTRAINT l_release_url_pkey PRIMARY KEY (id);
ALTER TABLE l_release_work ADD CONSTRAINT l_release_work_pkey PRIMARY KEY (id);
ALTER TABLE l_release_group_release_group ADD CONSTRAINT l_release_group_release_group_pkey PRIMARY KEY (id);
ALTER TABLE l_release_group_url ADD CONSTRAINT l_release_group_url_pkey PRIMARY KEY (id);
ALTER TABLE l_release_group_work ADD CONSTRAINT l_release_group_work_pkey PRIMARY KEY (id);
ALTER TABLE l_url_url ADD CONSTRAINT l_url_url_pkey PRIMARY KEY (id);
ALTER TABLE l_url_work ADD CONSTRAINT l_url_work_pkey PRIMARY KEY (id);
ALTER TABLE l_work_work ADD CONSTRAINT l_work_work_pkey PRIMARY KEY (id);

ALTER TABLE link ADD CONSTRAINT link_pkey PRIMARY KEY (id);
ALTER TABLE link_attribute ADD CONSTRAINT link_attribute_pkey PRIMARY KEY (link, attribute_type);
ALTER TABLE link_attribute_type ADD CONSTRAINT link_attribute_type_pkey PRIMARY KEY (id);
ALTER TABLE link_type ADD CONSTRAINT link_type_pkey PRIMARY KEY (id);
ALTER TABLE link_type_attribute_type ADD CONSTRAINT link_type_attribute_type_pkey PRIMARY KEY (link_type, attribute_type);

CREATE UNIQUE INDEX l_artist_artist_idx_uniq ON l_artist_artist (entity0, entity1, link);
CREATE INDEX l_artist_artist_idx_entity1 ON l_artist_artist (entity1);
CREATE UNIQUE INDEX l_artist_label_idx_uniq ON l_artist_label (entity0, entity1, link);
CREATE INDEX l_artist_label_idx_entity1 ON l_artist_label (entity1);
CREATE UNIQUE INDEX l_artist_recording_idx_uniq ON l_artist_recording (entity0, entity1, link);
CREATE INDEX l_artist_recording_idx_entity1 ON l_artist_recording (entity1);
CREATE UNIQUE INDEX l_artist_release_idx_uniq ON l_artist_release (entity0, entity1, link);
CREATE INDEX l_artist_release_idx_entity1 ON l_artist_release (entity1);
CREATE UNIQUE INDEX l_artist_release_group_idx_uniq ON l_artist_release_group (entity0, entity1, link);
CREATE INDEX l_artist_release_group_idx_entity1 ON l_artist_release_group (entity1);
CREATE UNIQUE INDEX l_artist_url_idx_uniq ON l_artist_url (entity0, entity1, link);
CREATE INDEX l_artist_url_idx_entity1 ON l_artist_url (entity1);
CREATE UNIQUE INDEX l_artist_work_idx_uniq ON l_artist_work (entity0, entity1, link);
CREATE INDEX l_artist_work_idx_entity1 ON l_artist_work (entity1);

CREATE UNIQUE INDEX l_label_label_idx_uniq ON l_label_label (entity0, entity1, link);
CREATE INDEX l_label_label_idx_entity1 ON l_label_label (entity1);
CREATE UNIQUE INDEX l_label_recording_idx_uniq ON l_label_recording (entity0, entity1, link);
CREATE INDEX l_label_recording_idx_entity1 ON l_label_recording (entity1);
CREATE UNIQUE INDEX l_label_release_idx_uniq ON l_label_release (entity0, entity1, link);
CREATE INDEX l_label_release_idx_entity1 ON l_label_release (entity1);
CREATE UNIQUE INDEX l_label_release_group_idx_uniq ON l_label_release_group (entity0, entity1, link);
CREATE INDEX l_label_release_group_idx_entity1 ON l_label_release_group (entity1);
CREATE UNIQUE INDEX l_label_url_idx_uniq ON l_label_url (entity0, entity1, link);
CREATE INDEX l_label_url_idx_entity1 ON l_label_url (entity1);
CREATE UNIQUE INDEX l_label_work_idx_uniq ON l_label_work (entity0, entity1, link);
CREATE INDEX l_label_work_idx_entity1 ON l_label_work (entity1);

CREATE UNIQUE INDEX l_recording_recording_idx_uniq ON l_recording_recording (entity0, entity1, link);
CREATE INDEX l_recording_recording_idx_entity1 ON l_recording_recording (entity1);
CREATE UNIQUE INDEX l_recording_release_idx_uniq ON l_recording_release (entity0, entity1, link);
CREATE INDEX l_recording_release_idx_entity1 ON l_recording_release (entity1);
CREATE UNIQUE INDEX l_recording_release_group_idx_uniq ON l_recording_release_group (entity0, entity1, link);
CREATE INDEX l_recording_release_group_idx_entity1 ON l_recording_release_group (entity1);
CREATE UNIQUE INDEX l_recording_url_idx_uniq ON l_recording_url (entity0, entity1, link);
CREATE INDEX l_recording_url_idx_entity1 ON l_recording_url (entity1);
CREATE UNIQUE INDEX l_recording_work_idx_uniq ON l_recording_work (entity0, entity1, link);
CREATE INDEX l_recording_work_idx_entity1 ON l_recording_work (entity1);

CREATE UNIQUE INDEX l_release_release_idx_uniq ON l_release_release (entity0, entity1, link);
CREATE INDEX l_release_release_idx_entity1 ON l_release_release (entity1);
CREATE UNIQUE INDEX l_release_release_group_idx_uniq ON l_release_release_group (entity0, entity1, link);
CREATE INDEX l_release_release_group_idx_entity1 ON l_release_release_group (entity1);
CREATE UNIQUE INDEX l_release_url_idx_uniq ON l_release_url (entity0, entity1, link);
CREATE INDEX l_release_url_idx_entity1 ON l_release_url (entity1);
CREATE UNIQUE INDEX l_release_work_idx_uniq ON l_release_work (entity0, entity1, link);
CREATE INDEX l_release_work_idx_entity1 ON l_release_work (entity1);

CREATE UNIQUE INDEX l_release_group_release_group_idx_uniq ON l_release_group_release_group (entity0, entity1, link);
CREATE INDEX l_release_group_release_group_idx_entity1 ON l_release_group_release_group (entity1);
CREATE UNIQUE INDEX l_release_group_url_idx_uniq ON l_release_group_url (entity0, entity1, link);
CREATE INDEX l_release_group_url_idx_entity1 ON l_release_group_url (entity1);
CREATE UNIQUE INDEX l_release_group_work_idx_uniq ON l_release_group_work (entity0, entity1, link);
CREATE INDEX l_release_group_work_idx_entity1 ON l_release_group_work (entity1);

CREATE UNIQUE INDEX l_url_url_idx_uniq ON l_url_url (entity0, entity1, link);
CREATE INDEX l_url_url_idx_entity1 ON l_url_url (entity1);
CREATE UNIQUE INDEX l_url_work_idx_uniq ON l_url_work (entity0, entity1, link);
CREATE INDEX l_url_work_idx_entity1 ON l_url_work (entity1);

CREATE UNIQUE INDEX l_work_work_idx_uniq ON l_work_work (entity0, entity1, link);
CREATE INDEX l_work_work_idx_entity1 ON l_work_work (entity1);

ALTER TABLE l_artist_artist ADD CONSTRAINT l_artist_artist_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_artist ADD CONSTRAINT l_artist_artist_fk_entity1 FOREIGN KEY (entity1) REFERENCES artist(id);
ALTER TABLE l_artist_artist ADD CONSTRAINT l_artist_artist_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_artist_label ADD CONSTRAINT l_artist_label_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_label ADD CONSTRAINT l_artist_label_fk_entity1 FOREIGN KEY (entity1) REFERENCES label(id);
ALTER TABLE l_artist_label ADD CONSTRAINT l_artist_label_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_artist_recording ADD CONSTRAINT l_artist_recording_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_recording ADD CONSTRAINT l_artist_recording_fk_entity1 FOREIGN KEY (entity1) REFERENCES recording(id);
ALTER TABLE l_artist_recording ADD CONSTRAINT l_artist_recording_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_artist_release ADD CONSTRAINT l_artist_release_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_release ADD CONSTRAINT l_artist_release_fk_entity1 FOREIGN KEY (entity1) REFERENCES release(id);
ALTER TABLE l_artist_release ADD CONSTRAINT l_artist_release_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_artist_release_group ADD CONSTRAINT l_artist_release_group_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_release_group ADD CONSTRAINT l_artist_release_group_fk_entity1 FOREIGN KEY (entity1) REFERENCES release_group(id);
ALTER TABLE l_artist_release_group ADD CONSTRAINT l_artist_release_group_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_artist_url ADD CONSTRAINT l_artist_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_url ADD CONSTRAINT l_artist_url_fk_entity1 FOREIGN KEY (entity1) REFERENCES url(id);
ALTER TABLE l_artist_url ADD CONSTRAINT l_artist_url_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_artist_work ADD CONSTRAINT l_artist_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_work ADD CONSTRAINT l_artist_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_artist_work ADD CONSTRAINT l_artist_work_fk_link FOREIGN KEY (link) REFERENCES link(id);

ALTER TABLE l_label_label ADD CONSTRAINT l_label_label_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
ALTER TABLE l_label_label ADD CONSTRAINT l_label_label_fk_entity1 FOREIGN KEY (entity1) REFERENCES label(id);
ALTER TABLE l_label_label ADD CONSTRAINT l_label_label_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_label_recording ADD CONSTRAINT l_label_recording_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
ALTER TABLE l_label_recording ADD CONSTRAINT l_label_recording_fk_entity1 FOREIGN KEY (entity1) REFERENCES recording(id);
ALTER TABLE l_label_recording ADD CONSTRAINT l_label_recording_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_label_release ADD CONSTRAINT l_label_release_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
ALTER TABLE l_label_release ADD CONSTRAINT l_label_release_fk_entity1 FOREIGN KEY (entity1) REFERENCES release(id);
ALTER TABLE l_label_release ADD CONSTRAINT l_label_release_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_label_release_group ADD CONSTRAINT l_label_release_group_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
ALTER TABLE l_label_release_group ADD CONSTRAINT l_label_release_group_fk_entity1 FOREIGN KEY (entity1) REFERENCES release_group(id);
ALTER TABLE l_label_release_group ADD CONSTRAINT l_label_release_group_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_label_url ADD CONSTRAINT l_label_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
ALTER TABLE l_label_url ADD CONSTRAINT l_label_url_fk_entity1 FOREIGN KEY (entity1) REFERENCES url(id);
ALTER TABLE l_label_url ADD CONSTRAINT l_label_url_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_label_work ADD CONSTRAINT l_label_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
ALTER TABLE l_label_work ADD CONSTRAINT l_label_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_label_work ADD CONSTRAINT l_label_work_fk_link FOREIGN KEY (link) REFERENCES link(id);

ALTER TABLE l_recording_recording ADD CONSTRAINT l_recording_recording_fk_entity0 FOREIGN KEY (entity0) REFERENCES recording(id);
ALTER TABLE l_recording_recording ADD CONSTRAINT l_recording_recording_fk_entity1 FOREIGN KEY (entity1) REFERENCES recording(id);
ALTER TABLE l_recording_recording ADD CONSTRAINT l_recording_recording_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_recording_release ADD CONSTRAINT l_recording_release_fk_entity0 FOREIGN KEY (entity0) REFERENCES recording(id);
ALTER TABLE l_recording_release ADD CONSTRAINT l_recording_release_fk_entity1 FOREIGN KEY (entity1) REFERENCES release(id);
ALTER TABLE l_recording_release ADD CONSTRAINT l_recording_release_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_recording_release_group ADD CONSTRAINT l_recording_release_group_fk_entity0 FOREIGN KEY (entity0) REFERENCES recording(id);
ALTER TABLE l_recording_release_group ADD CONSTRAINT l_recording_release_group_fk_entity1 FOREIGN KEY (entity1) REFERENCES release_group(id);
ALTER TABLE l_recording_release_group ADD CONSTRAINT l_recording_release_group_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_recording_url ADD CONSTRAINT l_recording_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES recording(id);
ALTER TABLE l_recording_url ADD CONSTRAINT l_recording_url_fk_entity1 FOREIGN KEY (entity1) REFERENCES url(id);
ALTER TABLE l_recording_url ADD CONSTRAINT l_recording_url_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_recording_work ADD CONSTRAINT l_recording_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES recording(id);
ALTER TABLE l_recording_work ADD CONSTRAINT l_recording_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_recording_work ADD CONSTRAINT l_recording_work_fk_link FOREIGN KEY (link) REFERENCES link(id);

ALTER TABLE l_release_release ADD CONSTRAINT l_release_release_fk_entity0 FOREIGN KEY (entity0) REFERENCES release(id);
ALTER TABLE l_release_release ADD CONSTRAINT l_release_release_fk_entity1 FOREIGN KEY (entity1) REFERENCES release(id);
ALTER TABLE l_release_release ADD CONSTRAINT l_release_release_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_release_release_group ADD CONSTRAINT l_release_release_group_fk_entity0 FOREIGN KEY (entity0) REFERENCES release(id);
ALTER TABLE l_release_release_group ADD CONSTRAINT l_release_release_group_fk_entity1 FOREIGN KEY (entity1) REFERENCES release_group(id);
ALTER TABLE l_release_release_group ADD CONSTRAINT l_release_release_group_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_release_url ADD CONSTRAINT l_release_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES release(id);
ALTER TABLE l_release_url ADD CONSTRAINT l_release_url_fk_entity1 FOREIGN KEY (entity1) REFERENCES url(id);
ALTER TABLE l_release_url ADD CONSTRAINT l_release_url_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_release_work ADD CONSTRAINT l_release_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES release(id);
ALTER TABLE l_release_work ADD CONSTRAINT l_release_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_release_work ADD CONSTRAINT l_release_work_fk_link FOREIGN KEY (link) REFERENCES link(id);

ALTER TABLE l_release_group_release_group ADD CONSTRAINT l_release_group_release_group_fk_entity0 FOREIGN KEY (entity0) REFERENCES release_group(id);
ALTER TABLE l_release_group_release_group ADD CONSTRAINT l_release_group_release_group_fk_entity1 FOREIGN KEY (entity1) REFERENCES release_group(id);
ALTER TABLE l_release_group_release_group ADD CONSTRAINT l_release_group_release_group_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_release_group_url ADD CONSTRAINT l_release_group_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES release_group(id);
ALTER TABLE l_release_group_url ADD CONSTRAINT l_release_group_url_fk_entity1 FOREIGN KEY (entity1) REFERENCES url(id);
ALTER TABLE l_release_group_url ADD CONSTRAINT l_release_group_url_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_release_group_work ADD CONSTRAINT l_release_group_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES release_group(id);
ALTER TABLE l_release_group_work ADD CONSTRAINT l_release_group_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_release_group_work ADD CONSTRAINT l_release_group_work_fk_link FOREIGN KEY (link) REFERENCES link(id);

ALTER TABLE l_url_url ADD CONSTRAINT l_url_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES url(id);
ALTER TABLE l_url_url ADD CONSTRAINT l_url_url_fk_entity1 FOREIGN KEY (entity1) REFERENCES url(id);
ALTER TABLE l_url_url ADD CONSTRAINT l_url_url_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_url_work ADD CONSTRAINT l_url_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES url(id);
ALTER TABLE l_url_work ADD CONSTRAINT l_url_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_url_work ADD CONSTRAINT l_url_work_fk_link FOREIGN KEY (link) REFERENCES link(id);

ALTER TABLE l_work_work ADD CONSTRAINT l_work_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES work(id);
ALTER TABLE l_work_work ADD CONSTRAINT l_work_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_work_work ADD CONSTRAINT l_work_work_fk_link FOREIGN KEY (link) REFERENCES link(id);

COMMIT;