BEGIN;

ALTER TABLE artist ADD COLUMN ended BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE label ADD COLUMN ended BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE link ADD COLUMN ended BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE artist SET ended = TRUE
WHERE end_date_year IS NOT NULL OR end_date_month IS NOT NULL OR end_date_day IS NOT NULL;

UPDATE label SET ended = TRUE
WHERE end_date_year IS NOT NULL OR end_date_month IS NOT NULL OR end_date_day IS NOT NULL;

UPDATE link SET ended = TRUE
WHERE end_date_year IS NOT NULL OR end_date_month IS NOT NULL OR end_date_day IS NOT NULL;

CREATE OR REPLACE FUNCTION end_date_implies_ended()
RETURNS trigger AS $$
BEGIN
    IF NEW.end_date_year IS NOT NULL OR
       NEW.end_date_month IS NOT NULL OR
       NEW.end_date_day IS NOT NULL
    THEN
        NEW.ended = TRUE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON artist
FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON label
FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON link
FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

ALTER TABLE artist ADD CONSTRAINT artist_ended_check
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

ALTER TABLE label ADD CONSTRAINT label_ended_check
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

ALTER TABLE link ADD CONSTRAINT link_ended_check
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
