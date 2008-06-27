-- Abstract: add "with time zone" to moderator.membersince and artistalias.lastused
-- Formerly called admin/sql/AddTimeZones.sql

\set ON_ERROR_STOP 1

BEGIN;

SET TIME ZONE 'PST+8PDT';

ALTER TABLE moderator
 ADD COLUMN membersince_tz TIMESTAMP WITH TIME ZONE;
ALTER TABLE moderator
 ALTER COLUMN membersince_tz SET DEFAULT now();

UPDATE moderator
 SET membersince_tz =
 TO_TIMESTAMP(
  membersince
  || '-'
  || EXTRACT(timezone_hour FROM membersince AT TIME ZONE 'UTC')
  ,
  'YYYY-MM-DD HH24:MI:SS.MS'
 );

UPDATE moderator SET membersince_tz = '1970-01-01 00:00:00+00'
  WHERE membersince_tz < '1970-01-02';

ALTER TABLE moderator RENAME COLUMN membersince TO membersince_notz;
ALTER TABLE moderator RENAME COLUMN membersince_tz TO membersince;

ALTER TABLE artistalias
 ADD COLUMN lastused_tz TIMESTAMP WITH TIME ZONE;

UPDATE artistalias
 SET lastused_tz =
 TO_TIMESTAMP(
  lastused
  || '-'
  || EXTRACT(timezone_hour FROM lastused AT TIME ZONE 'UTC')
  ,
  'YYYY-MM-DD HH24:MI:SS.MS'
 );

UPDATE artistalias SET lastused_tz = '1970-01-01 00:00:00+00'
  WHERE lastused_tz < '1970-01-02';

--ALTER TABLE artistalias ALTER COLUMN lastused_tz SET NOT NULL;
ALTER TABLE artistalias ADD CONSTRAINT artistalias_lastused_nn
  CHECK (lastused_tz IS NOT NULL);

ALTER TABLE artistalias RENAME COLUMN lastused TO lastused_notz;
ALTER TABLE artistalias RENAME COLUMN lastused_tz TO lastused;

SET TIME ZONE 'UTC';

COMMIT;

