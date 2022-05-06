\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION _median(INTEGER[]) RETURNS INTEGER AS $$
  WITH q AS (
      SELECT val
      FROM unnest($1) val
      WHERE VAL IS NOT NULL
      ORDER BY val
  )
  SELECT val
  FROM q
  LIMIT 1
  -- Subtracting (n + 1) % 2 creates a left bias
  OFFSET greatest(0, floor((select count(*) FROM q) / 2.0) - ((select count(*) + 1 FROM q) % 2));
$$ LANGUAGE sql IMMUTABLE;

DROP AGGREGATE IF EXISTS median(anyelement);

CREATE OR REPLACE AGGREGATE median(INTEGER) (
  SFUNC=array_append,
  STYPE=INTEGER[],
  FINALFUNC=_median,
  INITCOND='{}'
);

DROP AGGREGATE IF EXISTS array_accum(anyelement);

DROP AGGREGATE IF EXISTS array_cat_agg(anyarray);

CREATE OR REPLACE AGGREGATE array_cat_agg(int2[]) (
      sfunc       = array_cat,
      stype       = int2[],
      initcond    = '{}'
);

COMMIT;
