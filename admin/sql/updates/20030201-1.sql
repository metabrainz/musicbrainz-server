-- Abstract: add moderation.opentime, moderation.closetime, votes.votetime
-- Formerly called admin/sql/AddModVoteTimestamps.sql

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE moderation ADD COLUMN opentime TIMESTAMP WITH TIME ZONE;
ALTER TABLE moderation ADD COLUMN closetime TIMESTAMP WITH TIME ZONE;
ALTER TABLE moderation ALTER COLUMN opentime SET DEFAULT NOW();

ALTER TABLE votes ADD COLUMN votetime TIMESTAMP WITH TIME ZONE;
ALTER TABLE votes ALTER COLUMN votetime SET DEFAULT NOW();

-- These three statements are sloooowwwww....
--UPDATE moderation SET opentime = expiretime - INTERVAL '2 days';
--UPDATE moderation SET closetime = expiretime WHERE status > 1;
--UPDATE votes SET votetime = opentime + INTERVAL '1 minute'
--  FROM moderation
--  WHERE votes.rowid = moderation.id;

CREATE OR REPLACE FUNCTION before_update_moderation () RETURNS opaque AS '
begin

   if (OLD.status = 1 and NEW.status != 1) -- STATUS_OPEN
   then
      NEW.closetime := NOW();
   end if;

   return NEW;

end;
' LANGUAGE 'plpgsql';

CREATE TRIGGER b_upd_moderation BEFORE UPDATE ON moderation 
               FOR EACH ROW EXECUTE PROCEDURE before_update_moderation();

UPDATE moderation SET opentime = expiretime - INTERVAL '2 days';
UPDATE moderation SET closetime = expiretime WHERE status > 1;
UPDATE votes SET votetime = moderation.opentime + INTERVAL '1 second'
  FROM moderation 
  WHERE moderation.id = votes.rowid;

COMMIT;

