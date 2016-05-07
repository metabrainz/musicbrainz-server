\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE alternative_release (
    id                      SERIAL,
    gid                     UUID NOT NULL,
    release                 INTEGER NOT NULL,
    name                    VARCHAR,
    artist_credit           INTEGER,
    type                    INTEGER NOT NULL,
    language                INTEGER NOT NULL,
    script                  INTEGER NOT NULL,
    comment                 VARCHAR(255) NOT NULL DEFAULT ''
    CHECK (name != '')
);

CREATE TABLE alternative_release_type (
    id                  SERIAL,
    name                TEXT NOT NULL,
    parent              INTEGER,
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    gid                 UUID NOT NULL
);

CREATE TABLE alternative_medium (
    id                      SERIAL,
    medium                  INTEGER NOT NULL,
    alternative_release     INTEGER NOT NULL,
    name                    VARCHAR
    CHECK (name != '')
);

CREATE TABLE alternative_track (
    id                      SERIAL,
    name                    VARCHAR,
    artist_credit           INTEGER,
    ref_count               INTEGER NOT NULL DEFAULT 0
    CHECK (name != '' AND (name IS NOT NULL OR artist_credit IS NOT NULL))
);

CREATE TABLE alternative_medium_track (
    alternative_medium      INTEGER NOT NULL,
    track                   INTEGER NOT NULL,
    alternative_track       INTEGER NOT NULL
);

ALTER TABLE alternative_medium ADD CONSTRAINT alternative_medium_pkey PRIMARY KEY (id);
ALTER TABLE alternative_medium_track ADD CONSTRAINT alternative_medium_track_pkey PRIMARY KEY (alternative_medium, track);
ALTER TABLE alternative_release ADD CONSTRAINT alternative_release_pkey PRIMARY KEY (id);
ALTER TABLE alternative_release_type ADD CONSTRAINT alternative_release_type_pkey PRIMARY KEY (id);
ALTER TABLE alternative_track ADD CONSTRAINT alternative_track_pkey PRIMARY KEY (id);

CREATE INDEX alternative_release_idx_release ON alternative_release (release);
CREATE INDEX alternative_release_idx_name ON alternative_release (name);
CREATE INDEX alternative_release_idx_artist_credit ON alternative_release (artist_credit);
CREATE INDEX alternative_release_idx_language_script ON alternative_release (language, script);
CREATE UNIQUE INDEX alternative_release_idx_gid ON alternative_release (gid);
CREATE INDEX alternative_medium_idx_alternative_release ON alternative_medium (alternative_release);
CREATE INDEX alternative_track_idx_name ON alternative_track (name);
CREATE INDEX alternative_track_idx_artist_credit ON alternative_track (artist_credit);

CREATE OR REPLACE FUNCTION inc_nullable_artist_credit(row_id integer) RETURNS void AS $$
BEGIN
    IF row_id IS NOT NULL THEN
        PERFORM inc_ref_count('artist_credit', row_id, 1);
    END IF;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION dec_nullable_artist_credit(row_id integer) RETURNS void AS $$
BEGIN
    IF row_id IS NOT NULL THEN
        PERFORM dec_ref_count('artist_credit', row_id, 1);
    END IF;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_alternative_release_or_track() RETURNS trigger AS $$
BEGIN
    PERFORM inc_nullable_artist_credit(NEW.artist_credit);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_alternative_release_or_track() RETURNS trigger AS $$
BEGIN
    IF NEW.artist_credit IS DISTINCT FROM OLD.artist_credit THEN
        PERFORM inc_nullable_artist_credit(NEW.artist_credit);
        PERFORM dec_nullable_artist_credit(OLD.artist_credit);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_alternative_release_or_track() RETURNS trigger AS $$
BEGIN
    PERFORM dec_nullable_artist_credit(OLD.artist_credit);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_alternative_medium_track() RETURNS trigger AS $$
BEGIN
    PERFORM inc_ref_count('alternative_track', NEW.alternative_track, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_alternative_medium_track() RETURNS trigger AS $$
BEGIN
    IF NEW.alternative_track IS DISTINCT FROM OLD.alternative_track THEN
        PERFORM inc_ref_count('alternative_track', NEW.alternative_track, 1);
        PERFORM dec_ref_count('alternative_track', OLD.alternative_track, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_alternative_medium_track() RETURNS trigger AS $$
BEGIN
    PERFORM dec_ref_count('alternative_track', OLD.alternative_track, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

INSERT INTO alternative_release_type (id, name, parent, child_order, description, gid) VALUES
    (1, 'Translation', NULL, 0, '', generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/alternative_release_type/translation')),
    (2, 'Official translation', 1, 0, '', generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/alternative_release_type/official_translation')),
    (3, 'Exactly as on cover', NULL, 1, '', generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/alternative_release_type/exactly_as_on_cover'));

COMMIT;
