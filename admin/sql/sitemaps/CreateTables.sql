\set ON_ERROR_STOP 1

BEGIN;

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
    id                      INTEGER NOT NULL, -- FK, references musicbrainz.artist.id CASCADE
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE label_lastmod (
    id                      INTEGER NOT NULL, -- FK, references musicbrainz.label.id CASCADE
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE place_lastmod (
    id                      INTEGER NOT NULL, -- FK, references musicbrainz.place.id CASCADE
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE recording_lastmod (
    id                      INTEGER NOT NULL, -- FK, references musicbrainz.recording.id CASCADE
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE release_lastmod (
    id                      INTEGER NOT NULL, -- FK, references musicbrainz.release.id CASCADE
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE release_group_lastmod (
    id                      INTEGER NOT NULL, -- FK, references musicbrainz.release_group.id CASCADE
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

CREATE TABLE work_lastmod (
    id                      INTEGER NOT NULL, -- FK, references musicbrainz.work.id CASCADE
    url                     VARCHAR(128) NOT NULL,
    paginated               BOOLEAN NOT NULL,
    sitemap_suffix_key      VARCHAR(50) NOT NULL,
    jsonld_sha1             BYTEA NOT NULL,
    last_modified           TIMESTAMP WITH TIME ZONE NOT NULL,
    replication_sequence    INTEGER NOT NULL
);

COMMIT;
