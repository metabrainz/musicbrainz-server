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

COMMIT;
