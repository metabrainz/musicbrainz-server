CREATE INDEX CONCURRENTLY artist_idx_area ON artist (area);
CREATE INDEX CONCURRENTLY artist_idx_begin_area ON artist (begin_area);
CREATE INDEX CONCURRENTLY artist_idx_end_area ON artist (end_area);

CREATE INDEX CONCURRENTLY label_idx_area ON label (area);

-- rename index, functionally
CREATE INDEX CONCURRENTLY release_country_idx_country ON release_country (country);
DROP INDEX IF EXISTS release_country_country_idx;
