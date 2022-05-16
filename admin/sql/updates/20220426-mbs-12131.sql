\set ON_ERROR_STOP 1

BEGIN;

DROP AGGREGATE IF EXISTS median(anyelement);
DROP FUNCTION IF EXISTS _median(anyarray);

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

CREATE OR REPLACE AGGREGATE median(INTEGER) (
  SFUNC=array_append,
  STYPE=INTEGER[],
  FINALFUNC=_median,
  INITCOND='{}'
);

DROP AGGREGATE IF EXISTS array_accum(anyelement);

COMMIT;
