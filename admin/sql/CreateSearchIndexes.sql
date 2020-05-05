\unset ON_ERROR_STOP

CREATE INDEX artist_idx_txt ON artist USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX artist_idx_txt_sort ON artist USING gin(musicbrainz.mb_simple_tsvector(sort_name));

CREATE INDEX artist_alias_idx_txt ON artist_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX artist_alias_idx_txt_sort ON artist_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));

CREATE INDEX artist_credit_idx_txt ON artist_credit USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX artist_credit_name_idx_txt ON artist_credit_name USING gin(musicbrainz.mb_simple_tsvector(name));

CREATE INDEX event_idx_txt ON event USING gin(musicbrainz.mb_simple_tsvector(name));

CREATE INDEX event_alias_idx_txt ON event_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX event_alias_idx_txt_sort ON event_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));

CREATE INDEX instrument_idx_txt ON instrument USING gin(musicbrainz.mb_simple_tsvector(name));

CREATE INDEX label_idx_txt ON label USING gin(musicbrainz.mb_simple_tsvector(name));

CREATE INDEX label_alias_idx_txt ON label_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX label_alias_idx_txt_sort ON label_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));

CREATE INDEX release_idx_txt ON release USING gin(musicbrainz.mb_simple_tsvector(name));

CREATE INDEX release_alias_idx_txt ON release_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX release_alias_idx_txt_sort ON release_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));

CREATE INDEX release_group_idx_txt ON release_group USING gin(musicbrainz.mb_simple_tsvector(name));

CREATE INDEX release_group_alias_idx_txt ON release_group_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX release_group_alias_idx_txt_sort ON release_group_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));

CREATE INDEX recording_idx_txt ON recording USING gin(musicbrainz.mb_simple_tsvector(name));

CREATE INDEX recording_alias_idx_txt ON recording_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX recording_alias_idx_txt_sort ON recording_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));

CREATE INDEX series_idx_txt ON series USING gin(musicbrainz.mb_simple_tsvector(name));

CREATE INDEX series_alias_idx_txt ON series_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX series_alias_idx_txt_sort ON series_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));

CREATE INDEX work_idx_txt ON work USING gin(musicbrainz.mb_simple_tsvector(name));

CREATE INDEX work_alias_idx_txt ON work_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX work_alias_idx_txt_sort ON work_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));

CREATE INDEX area_idx_name_txt ON area USING gin(musicbrainz.mb_simple_tsvector(name));

CREATE INDEX area_alias_idx_txt ON area_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX area_alias_idx_txt_sort ON area_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));

CREATE INDEX place_idx_name_txt ON place USING gin(musicbrainz.mb_simple_tsvector(name));

CREATE INDEX place_alias_idx_txt ON place_alias USING gin(musicbrainz.mb_simple_tsvector(name));
CREATE INDEX place_alias_idx_txt_sort ON place_alias USING gin(musicbrainz.mb_simple_tsvector(sort_name));

CREATE INDEX tag_idx_name_txt ON tag USING gin(musicbrainz.mb_simple_tsvector(name));
