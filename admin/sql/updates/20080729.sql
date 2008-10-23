\set ON_ERROR_STOP 1

BEGIN;

-- Change prevvalue in moderation tables to be a text value, not varchar(255)
DROP VIEW moderation_all;
ALTER TABLE moderation_open ALTER COLUMN prevvalue TYPE TEXT;
ALTER TABLE moderation_closed ALTER COLUMN prevvalue TYPE TEXT;

ALTER TABLE moderation_open ALTER COLUMN prevvalue SET NOT NULL;
ALTER TABLE moderation_closed ALTER COLUMN prevvalue SET NOT NULL;

CREATE VIEW moderation_all AS
    SELECT * FROM moderation_open
    UNION ALL
    SELECT * FROM moderation_closed;

-- Add a date added column to album table to support the upcoming discographies feature
ALTER TABLE albummeta ADD COLUMN dateadded TIMESTAMP WITH TIME ZONE DEFAULT '1970-01-01 00:00:00-00';
ALTER TABLE albummeta ALTER COLUMN dateadded SET DEFAULT now();

-- Change the track name to TEXT to allow longer than 255 char titles
ALTER TABLE track ALTER COLUMN name TYPE TEXT;

COMMIT;
