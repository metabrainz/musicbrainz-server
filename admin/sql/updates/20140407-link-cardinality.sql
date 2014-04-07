\set ON_ERROR_STOP 1
BEGIN;
    ALTER TABLE musicbrainz.link_type ADD COLUMN entity0_cardinality integer,
                                      ADD COLUMN entity1_cardinality integer;
COMMIT;
