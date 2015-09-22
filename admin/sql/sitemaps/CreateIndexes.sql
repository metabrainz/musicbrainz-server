\set ON_ERROR_STOP 1

BEGIN;

SET search_path = 'sitemaps';

CREATE UNIQUE INDEX artist_lastmod_idx_url ON artist_lastmod (url);
CREATE UNIQUE INDEX tmp_checked_entities_idx_uniq ON tmp_checked_entities (id, entity_type);
CREATE UNIQUE INDEX label_lastmod_idx_url ON label_lastmod (url);
CREATE UNIQUE INDEX place_lastmod_idx_url ON place_lastmod (url);
CREATE UNIQUE INDEX recording_lastmod_idx_url ON recording_lastmod (url);
CREATE UNIQUE INDEX release_lastmod_idx_url ON release_lastmod (url);
CREATE UNIQUE INDEX release_group_lastmod_idx_url ON release_group_lastmod (url);
CREATE UNIQUE INDEX work_lastmod_idx_url ON work_lastmod (url);

COMMIT;
