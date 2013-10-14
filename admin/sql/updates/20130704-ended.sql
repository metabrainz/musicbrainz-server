\set ON_ERROR_STOP 1
BEGIN;

------------------------
-- CREATE NEW COLUMNS --
------------------------

ALTER TABLE area_alias ADD COLUMN ended BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE artist_alias ADD COLUMN ended BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE label_alias ADD COLUMN ended BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE work_alias ADD COLUMN ended BOOLEAN NOT NULL DEFAULT FALSE;

-----------------------
-- TRUE IF END DATES --
-----------------------

UPDATE area_alias SET ended = TRUE
WHERE end_date_year IS NOT NULL OR end_date_month IS NOT NULL OR end_date_day IS NOT NULL;

UPDATE artist_alias SET ended = TRUE
WHERE end_date_year IS NOT NULL OR end_date_month IS NOT NULL OR end_date_day IS NOT NULL;

UPDATE label_alias SET ended = TRUE
WHERE end_date_year IS NOT NULL OR end_date_month IS NOT NULL OR end_date_day IS NOT NULL;

UPDATE work_alias SET ended = TRUE
WHERE end_date_year IS NOT NULL OR end_date_month IS NOT NULL OR end_date_day IS NOT NULL;

---------------------
-- ADD CONSTRAINTS --
---------------------

ALTER TABLE area_alias ADD CONSTRAINT area_alias_ended_check
CHECK (
  (
    -- If any end date fields are not null, then ended must be true
    (end_date_year IS NOT NULL OR
     end_date_month IS NOT NULL OR
     end_date_day IS NOT NULL) AND
    ended = TRUE
  ) OR (
    -- Otherwise, all end date fields must be null
    (end_date_year IS NULL AND
     end_date_month IS NULL AND
     end_date_day IS NULL)
  )
);

ALTER TABLE artist_alias ADD CONSTRAINT artist_alias_ended_check
CHECK (
  (
    -- If any end date fields are not null, then ended must be true
    (end_date_year IS NOT NULL OR
     end_date_month IS NOT NULL OR
     end_date_day IS NOT NULL) AND
    ended = TRUE
  ) OR (
    -- Otherwise, all end date fields must be null
    (end_date_year IS NULL AND
     end_date_month IS NULL AND
     end_date_day IS NULL)
  )
);

ALTER TABLE label_alias ADD CONSTRAINT label_alias_ended_check
CHECK (
  (
    -- If any end date fields are not null, then ended must be true
    (end_date_year IS NOT NULL OR
     end_date_month IS NOT NULL OR
     end_date_day IS NOT NULL) AND
    ended = TRUE
  ) OR (
    -- Otherwise, all end date fields must be null
    (end_date_year IS NULL AND
     end_date_month IS NULL AND
     end_date_day IS NULL)
  )
);

ALTER TABLE work_alias ADD CONSTRAINT work_alias_ended_check
CHECK (
  (
    -- If any end date fields are not null, then ended must be true
    (end_date_year IS NOT NULL OR
     end_date_month IS NOT NULL OR
     end_date_day IS NOT NULL) AND
    ended = TRUE
  ) OR (
    -- Otherwise, all end date fields must be null
    (end_date_year IS NULL AND
     end_date_month IS NULL AND
     end_date_day IS NULL)
  )
);


COMMIT;
