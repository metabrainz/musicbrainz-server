\set ON_ERROR_STOP 1

CREATE INDEX IF NOT EXISTS place_idx_geo ON place USING gist (ll_to_earth(coordinates[0], coordinates[1])) WHERE coordinates IS NOT NULL;
