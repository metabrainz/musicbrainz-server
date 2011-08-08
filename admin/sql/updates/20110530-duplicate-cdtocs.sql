BEGIN;

DELETE FROM medium_cdtoc
USING (
  SELECT
    id, row_number() OVER ( PARTITION BY medium, cdtoc )
  FROM medium_cdtoc
) s
WHERE s.row_number > 1 AND medium_cdtoc.id = s.id;

CREATE UNIQUE INDEX medium_cdtoc_idx_uniq ON medium_cdtoc (medium, cdtoc);

COMMIT;
