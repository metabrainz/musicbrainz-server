\unset ON_ERROR_STOP

CREATE INDEX artist_name_idx_name_txt ON artist_name USING gin(to_tsvector('mb_simple', name));
CREATE INDEX label_name_idx_name_txt ON label_name USING gin(to_tsvector('mb_simple', name));
CREATE INDEX release_name_idx_name_txt ON release_name USING gin(to_tsvector('mb_simple', name));
CREATE INDEX track_name_idx_name_txt ON track_name USING gin(to_tsvector('mb_simple', name));
CREATE INDEX work_name_idx_name_txt ON work_name USING gin(to_tsvector('mb_simple', name));
CREATE INDEX area_idx_name_txt ON area USING gin(to_tsvector('mb_simple', name));
CREATE INDEX tag_idx_name_txt ON tag USING gin(to_tsvector('mb_simple', name));
