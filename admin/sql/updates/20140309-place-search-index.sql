\unset ON_ERROR_STOP

CREATE INDEX place_idx_name_txt ON place USING gin(to_tsvector('mb_simple', name));
