-- Abstract: add "with time zone" to currentstat.lastupdated, moderation.expiretime
-- Abstract: also drop the temporary columns left in place by the last update
-- Formerly called admin/sql/MoreTimezones20030401.sql

\set ON_ERROR_STOP 1

set TIME ZONE 'UTC';

BEGIN;

ALTER TABLE currentstat ADD COLUMN lastupdated_tz TIMESTAMP WITH TIME ZONE;
UPDATE currentstat SET lastupdated_tz = lastupdated;
ALTER TABLE currentstat ALTER COLUMN lastupdated_tz SET NOT NULL;
ALTER TABLE currentstat ALTER COLUMN lastupdated_tz SET DEFAULT NOW();

ALTER TABLE currentstat RENAME COLUMN lastupdated TO lastupdated_notz;
ALTER TABLE currentstat RENAME COLUMN lastupdated_tz TO lastupdated;
ALTER TABLE currentstat DROP COLUMN lastupdated_notz;

COMMIT;

BEGIN;

ALTER TABLE moderation ADD COLUMN expiretime_tz TIMESTAMP WITH TIME ZONE;
UPDATE moderation SET expiretime_tz = expiretime;
ALTER TABLE moderation ALTER COLUMN expiretime_tz SET NOT NULL;

DROP INDEX moderation_expiretimeindex;
ALTER TABLE moderation RENAME COLUMN expiretime TO expiretime_notz;
ALTER TABLE moderation RENAME COLUMN expiretime_tz TO expiretime;
ALTER TABLE moderation DROP COLUMN expiretime_notz;
CREATE INDEX moderation_expiretimeindex ON moderation (expiretime);

COMMIT;

BEGIN;

ALTER TABLE moderator DROP COLUMN membersince_notz;
ALTER TABLE artistalias DROP COLUMN lastused_notz;

COMMIT;

