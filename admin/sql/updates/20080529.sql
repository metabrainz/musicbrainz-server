\set ON_ERROR_STOP 1

BEGIN;

-- Drop the TRM tables
DROP TABLE trmjoin CASCADE;
DROP TABLE trmjoin_stat CASCADE;
DROP TABLE trm CASCADE;
DROP TABLE trm_stat CASCADE;

-- Remove the various trmids columns
ALTER TABLE albummeta DROP COLUMN trmids;
ALTER TABLE stats DROP COLUMN trmids;

-- Remove the TRM edits from the database

-- Remove moderation notes in TRM edits
DELETE FROM moderation_note_open where id IN (select moderation_note_open.id 
					        from moderation_note_open, moderation_open 
					       where moderation_open.id = moderation_note_open.moderation 
					         AND moderation_open.type IN (22, 27)
					     );
DELETE FROM moderation_note_closed where id IN (select moderation_note_closed.id 
					  	  from moderation_note_closed, moderation_closed 
						 where moderation_closed.id = moderation_note_closed.moderation 
					           AND moderation_closed.type IN (22, 27)
					     );
delete from vote_open where id in (select vote_open.id from vote_open, moderation_open where moderation_open.id = vote_open.moderation and moderation_open.type IN (22, 27));
delete from vote_closed where id in (select vote_closed.id 
				       from vote_closed, moderation_closed 
				      where moderation_closed.id = vote_closed.moderation 
				        and moderation_closed.type IN (22, 27));

DELETE FROM moderation_closed where type = 22 or type = 27;
DELETE FROM moderation_open where type = 22 or type = 27;

COMMIT;
