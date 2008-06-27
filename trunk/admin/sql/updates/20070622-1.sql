-- Abstract: Create tag tables in the main DB

\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE tag
(
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    refcount            INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE artist_tag
(
    artist              INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    count               INTEGER NOT NULL
);

CREATE TABLE release_tag
(
    release             INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    count               INTEGER NOT NULL
);

CREATE TABLE track_tag
(
    track               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    count               INTEGER NOT NULL
);

CREATE TABLE label_tag
(
    label               INTEGER NOT NULL,
    tag                 INTEGER NOT NULL,
    count               INTEGER NOT NULL
);

-- primary keys
ALTER TABLE tag ADD CONSTRAINT tag_pkey PRIMARY KEY (id);

ALTER TABLE artist_tag ADD CONSTRAINT artist_tag_pkey PRIMARY KEY (artist, tag);
ALTER TABLE release_tag ADD CONSTRAINT release_tag_pkey PRIMARY KEY (release, tag);
ALTER TABLE track_tag ADD CONSTRAINT track_tag_pkey PRIMARY KEY (track, tag);
ALTER TABLE label_tag ADD CONSTRAINT label_tag_pkey PRIMARY KEY (label, tag);

-- indexes
CREATE UNIQUE INDEX tag_idx_name ON tag (name);

CREATE INDEX artist_tag_idx_artist ON artist_tag (artist);
CREATE INDEX artist_tag_idx_tag ON artist_tag (tag);
CREATE INDEX release_tag_idx_release ON release_tag (release);
CREATE INDEX release_tag_idx_tag ON release_tag (tag);
CREATE INDEX track_tag_idx_track ON track_tag (track);
CREATE INDEX track_tag_idx_tag ON track_tag (tag);
CREATE INDEX label_tag_idx_label ON label_tag (label);
CREATE INDEX label_tag_idx_tag ON label_tag (tag);

-- Functions

create or replace function a_ins_tag () returns trigger as '
begin
    UPDATE  tag
    SET     refcount = refcount + 1
    WHERE   id = NEW.tag;

    return NULL;
end;
' language 'plpgsql';

create or replace function a_del_tag () returns trigger as '
declare
    ref_count integer;
begin

    SELECT INTO ref_count refcount FROM tag WHERE id = OLD.tag;
    IF ref_count = 1 THEN
         DELETE FROM tag WHERE id = OLD.tag;
    ELSE
         UPDATE  tag
         SET     refcount = refcount - 1
         WHERE   id = OLD.tag;
    END IF;

    return NULL;
end;
' language 'plpgsql';

COMMIT;

-- vi: set ts=8 sw=8 et tw=0 :
