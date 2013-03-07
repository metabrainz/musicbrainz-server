\set ON_ERROR_STOP 1
BEGIN;

UPDATE medium
SET track_count = tc.count
FROM (SELECT count(id),medium FROM track GROUP BY medium) tc
WHERE tc.medium = medium.id;

COMMIT;
