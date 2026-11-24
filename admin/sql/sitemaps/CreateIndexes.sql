\set ON_ERROR_STOP 1

BEGIN;

SET search_path = 'sitemaps';

CREATE INDEX artist_lastmod_idx_id ON artist_lastmod (id);
CREATE INDEX label_lastmod_idx_id ON label_lastmod (id);
CREATE INDEX place_lastmod_idx_id ON place_lastmod (id);
CREATE INDEX recording_lastmod_idx_id ON recording_lastmod (id);
CREATE INDEX release_lastmod_idx_id ON release_lastmod (id);
CREATE INDEX release_group_lastmod_idx_id ON release_group_lastmod (id);
CREATE INDEX work_lastmod_idx_id ON work_lastmod (id);

CREATE UNIQUE INDEX artist_lastmod_idx_url ON artist_lastmod (url);
CREATE UNIQUE INDEX tmp_checked_entities_idx_uniq ON tmp_checked_entities (id, entity_type);
CREATE UNIQUE INDEX label_lastmod_idx_url ON label_lastmod (url);
CREATE UNIQUE INDEX place_lastmod_idx_url ON place_lastmod (url);
CREATE UNIQUE INDEX recording_lastmod_idx_url ON recording_lastmod (url);
CREATE UNIQUE INDEX release_lastmod_idx_url ON release_lastmod (url);
CREATE UNIQUE INDEX release_group_lastmod_idx_url ON release_group_lastmod (url);
CREATE UNIQUE INDEX work_lastmod_idx_url ON work_lastmod (url);

COMMIT;
