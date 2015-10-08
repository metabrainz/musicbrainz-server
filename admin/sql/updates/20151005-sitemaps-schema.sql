\set ON_ERROR_STOP 1
BEGIN;

DROP TABLE work_lastmod;

CREATE SCHEMA sitemaps;
SET search_path = 'sitemaps';

CREATE TABLE control (
    last_processed_replication_sequence     INTEGER,
    overall_sitemaps_replication_sequence   INTEGER,
    building_overall_sitemaps               BOOLEAN NOT NULL
);

CREATE TABLE tmp_checked_entities (
    id          INTEGER NOT NULL,
    entity_type VARCHAR(50) NOT NULL
);

CREATE TABLE artist_lastmod (
    id                      INTEGER NOT NULL,
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE label_lastmod (
    id                      INTEGER NOT NULL,
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE place_lastmod (
    id                      INTEGER NOT NULL,
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE recording_lastmod (
    id                      INTEGER NOT NULL,
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE release_lastmod (
    id                      INTEGER NOT NULL,
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE release_group_lastmod (
    id                      INTEGER NOT NULL,
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE work_lastmod (
    id                      INTEGER NOT NULL,
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

ALTER TABLE artist_lastmod
   ADD CONSTRAINT artist_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.artist(id)
   ON DELETE CASCADE;

ALTER TABLE label_lastmod
   ADD CONSTRAINT label_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.label(id)
   ON DELETE CASCADE;

ALTER TABLE place_lastmod
   ADD CONSTRAINT place_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.place(id)
   ON DELETE CASCADE;

ALTER TABLE recording_lastmod
   ADD CONSTRAINT recording_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.recording(id)
   ON DELETE CASCADE;

ALTER TABLE release_group_lastmod
   ADD CONSTRAINT release_group_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.release_group(id)
   ON DELETE CASCADE;

ALTER TABLE release_lastmod
   ADD CONSTRAINT release_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.release(id)
   ON DELETE CASCADE;

ALTER TABLE work_lastmod
   ADD CONSTRAINT work_lastmod_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.work(id)
   ON DELETE CASCADE;

CREATE UNIQUE INDEX artist_lastmod_idx_url ON artist_lastmod (url);
CREATE UNIQUE INDEX tmp_checked_entities_idx_uniq ON tmp_checked_entities (id, entity_type);
CREATE UNIQUE INDEX label_lastmod_idx_url ON label_lastmod (url);
CREATE UNIQUE INDEX place_lastmod_idx_url ON place_lastmod (url);
CREATE UNIQUE INDEX recording_lastmod_idx_url ON recording_lastmod (url);
CREATE UNIQUE INDEX release_lastmod_idx_url ON release_lastmod (url);
CREATE UNIQUE INDEX release_group_lastmod_idx_url ON release_group_lastmod (url);
CREATE UNIQUE INDEX work_lastmod_idx_url ON work_lastmod (url);

COMMIT;
