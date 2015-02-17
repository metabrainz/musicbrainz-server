\set ON_ERROR_STOP 1
BEGIN;
DROP INDEX IF EXISTS edit_instrument_idx;
CREATE INDEX edit_instrument_idx ON edit_instrument (instrument);

DROP INDEX IF EXISTS l_area_instrument_idx_uniq;
CREATE UNIQUE INDEX l_area_instrument_idx_uniq ON l_area_instrument (entity0, entity1, link, link_order);

DROP INDEX IF EXISTS l_artist_instrument_idx_uniq;
CREATE UNIQUE INDEX l_artist_instrument_idx_uniq ON l_artist_instrument (entity0, entity1, link, link_order);

DROP INDEX IF EXISTS l_area_instrument_idx_entity1;
CREATE INDEX l_area_instrument_idx_entity1 ON l_area_instrument (entity1);

DROP INDEX IF EXISTS l_artist_instrument_idx_entity1;
CREATE INDEX l_artist_instrument_idx_entity1 ON l_artist_instrument (entity1);
COMMIT;
