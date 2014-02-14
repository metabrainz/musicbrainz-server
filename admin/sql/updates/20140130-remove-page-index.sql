\set ON_ERROR_STOP 1
BEGIN;

SET search_path = musicbrainz;

DROP INDEX area_idx_page;
DROP INDEX artist_idx_page;
DROP INDEX label_idx_page;
DROP INDEX place_idx_page;
DROP INDEX release_idx_page;
DROP INDEX release_group_idx_page;
DROP INDEX work_idx_page;

DROP FUNCTION page_index(txt varchar);
DROP FUNCTION page_index_max(txt varchar);

COMMIT;
