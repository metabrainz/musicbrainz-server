\set ON_ERROR_STOP 1
BEGIN;

DROP INDEX IF EXISTS artist_gid_redirect_idx_gid;
DROP INDEX IF EXISTS recording_gid_redirect_idx_gid;
DROP INDEX IF EXISTS track_gid_redirect_idx_gid;
DROP INDEX IF EXISTS url_gid_redirect_idx_gid;
DROP INDEX IF EXISTS work_gid_redirect_idx_gid;

DROP INDEX IF EXISTS area_gid_redirect_idx_new_id;
DROP INDEX IF EXISTS artist_gid_redirect_idx_new_id;
DROP INDEX IF EXISTS event_gid_redirect_idx_new_id;
DROP INDEX IF EXISTS instrument_gid_redirect_idx_new_id;
DROP INDEX IF EXISTS label_gid_redirect_idx_new_id;
DROP INDEX IF EXISTS place_gid_redirect_idx_new_id;
DROP INDEX IF EXISTS recording_gid_redirect_idx_new_id;
DROP INDEX IF EXISTS release_gid_redirect_idx_new_id;
DROP INDEX IF EXISTS release_group_gid_redirect_idx_new_id;
DROP INDEX IF EXISTS series_gid_redirect_idx_new_id;
DROP INDEX IF EXISTS track_gid_redirect_idx_new_id;
DROP INDEX IF EXISTS url_gid_redirect_idx_new_id;
DROP INDEX IF EXISTS work_gid_redirect_idx_new_id;

CREATE INDEX area_gid_redirect_idx_new_id ON area_gid_redirect (new_id);
CREATE INDEX artist_gid_redirect_idx_new_id ON artist_gid_redirect (new_id);
CREATE INDEX event_gid_redirect_idx_new_id ON event_gid_redirect (new_id);
CREATE INDEX instrument_gid_redirect_idx_new_id ON instrument_gid_redirect (new_id);
CREATE INDEX label_gid_redirect_idx_new_id ON label_gid_redirect (new_id);
CREATE INDEX place_gid_redirect_idx_new_id ON place_gid_redirect (new_id);
CREATE INDEX recording_gid_redirect_idx_new_id ON recording_gid_redirect (new_id);
CREATE INDEX release_gid_redirect_idx_new_id ON release_gid_redirect (new_id);
CREATE INDEX release_group_gid_redirect_idx_new_id ON release_group_gid_redirect (new_id);
CREATE INDEX series_gid_redirect_idx_new_id ON series_gid_redirect (new_id);
CREATE INDEX track_gid_redirect_idx_new_id ON track_gid_redirect (new_id);
CREATE INDEX url_gid_redirect_idx_new_id ON url_gid_redirect (new_id);
CREATE INDEX work_gid_redirect_idx_new_id ON work_gid_redirect (new_id);

COMMIT;
