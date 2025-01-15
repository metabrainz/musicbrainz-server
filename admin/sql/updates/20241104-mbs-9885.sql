\set ON_ERROR_STOP 1

BEGIN;

UPDATE artist
SET end_date_day = NULL,
    end_date_month = NULL,
    end_date_year = NULL,
    end_area = NULL,
    ended = FALSE
WHERE type = 4;

ALTER TABLE artist
DROP CONSTRAINT IF EXISTS character_type_implies_no_end;

ALTER TABLE artist
ADD CONSTRAINT character_type_implies_no_end CHECK (
  type != 4 OR (
    end_date_day IS NULL AND
    end_date_month IS NULL AND
    end_date_year IS NULL AND
    end_area IS NULL AND
    ended = FALSE
  )
);

COMMIT;
