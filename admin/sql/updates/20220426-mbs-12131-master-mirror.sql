\set ON_ERROR_STOP 1

BEGIN;

DROP AGGREGATE IF EXISTS array_cat_agg(anyarray);

CREATE OR REPLACE AGGREGATE array_cat_agg(int2[]) (
      sfunc       = array_cat,
      stype       = int2[],
      initcond    = '{}'
);

COMMIT;
