-- Abstract: Splitting the moderation data into "open" and "closed" tables.
-- Abstract: Part 3: create indexes, foreign keys, triggers, views etc.

\set ON_ERROR_STOP 1

SET sort_mem=512000;

BEGIN;

-- In theory if we're perfect we could drop these tables here.
-- However apart from the extra disk space required, there's no harm now in
-- just renaming them out of the way, just in case we messed up...
-- This also means we can't accidentally reference these tables from now on
ALTER TABLE moderation RENAME TO old_moderation;
ALTER TABLE moderationnote RENAME TO old_moderationnote;
ALTER TABLE votes RENAME TO old_votes;

-- However we have to drop the foreign constraints, to allow referenced data
-- to be deleted
ALTER TABLE old_moderation DROP CONSTRAINT moderation_fk_artist;
-- the other FKs reference the old moderation table and "moderator", so no
-- need to drop these ones

SELECT SETVAL('moderation_open_id_seq', NEXTVAL('moderation_id_seq'));
SELECT SETVAL('moderation_note_open_id_seq', NEXTVAL('moderationnote_id_seq'));
SELECT SETVAL('vote_open_id_seq', NEXTVAL('votes_id_seq'));

ALTER TABLE moderation_open ADD CONSTRAINT moderation_open_pkey PRIMARY KEY (id);
ALTER TABLE moderation_note_open ADD CONSTRAINT moderation_note_open_pkey PRIMARY KEY (id);
ALTER TABLE vote_open ADD CONSTRAINT vote_open_pkey PRIMARY KEY (id);
ALTER TABLE moderation_closed ADD CONSTRAINT moderation_closed_pkey PRIMARY KEY (id);
ALTER TABLE moderation_note_closed ADD CONSTRAINT moderation_note_closed_pkey PRIMARY KEY (id);
ALTER TABLE vote_closed ADD CONSTRAINT vote_closed_pkey PRIMARY KEY (id);

CREATE INDEX moderation_open_idx_moderator ON moderation_open (moderator);
CREATE INDEX moderation_open_idx_expiretime ON moderation_open (expiretime);
CREATE INDEX moderation_open_idx_status ON moderation_open (status);
CREATE INDEX moderation_open_idx_artist ON moderation_open (artist);
CREATE INDEX moderation_open_idx_rowid ON moderation_open (rowid);

CREATE INDEX moderation_note_open_idx_moderation ON moderation_note_open (moderation);

CREATE INDEX vote_open_idx_moderator ON vote_open (moderator);
CREATE INDEX vote_open_idx_moderation ON vote_open (moderation);

CREATE INDEX moderation_closed_idx_moderator ON moderation_closed (moderator);
CREATE INDEX moderation_closed_idx_expiretime ON moderation_closed (expiretime);
CREATE INDEX moderation_closed_idx_status ON moderation_closed (status);
CREATE INDEX moderation_closed_idx_artist ON moderation_closed (artist);
CREATE INDEX moderation_closed_idx_rowid ON moderation_closed (rowid);

CREATE INDEX moderation_note_closed_idx_moderation ON moderation_note_closed (moderation);

CREATE INDEX vote_closed_idx_moderator ON vote_closed (moderator);
CREATE INDEX vote_closed_idx_moderation ON vote_closed (moderation);

-- This should have been dealt with by a previous upgrade, but it can't hurt
-- to do it again
DELETE FROM moderation_note_closed WHERE moderator = 0;

ALTER TABLE moderation_open
    ADD CONSTRAINT moderation_open_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE moderation_open
    ADD CONSTRAINT moderation_open_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE moderation_note_open
    ADD CONSTRAINT moderation_note_open_fk_moderation
    FOREIGN KEY (moderation)
    REFERENCES moderation_open(id);

ALTER TABLE moderation_note_open
    ADD CONSTRAINT moderation_note_open_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE vote_open
    ADD CONSTRAINT vote_open_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE vote_open
    ADD CONSTRAINT vote_open_fk_moderation
    FOREIGN KEY (moderation)
    REFERENCES moderation_open(id);

ALTER TABLE moderation_closed
    ADD CONSTRAINT moderation_closed_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE moderation_closed
    ADD CONSTRAINT moderation_closed_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE moderation_note_closed
    ADD CONSTRAINT moderation_note_closed_fk_moderation
    FOREIGN KEY (moderation)
    REFERENCES moderation_closed(id);

ALTER TABLE moderation_note_closed
    ADD CONSTRAINT moderation_note_closed_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE vote_closed
    ADD CONSTRAINT vote_closed_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE vote_closed
    ADD CONSTRAINT vote_closed_fk_moderation
    FOREIGN KEY (moderation)
    REFERENCES moderation_closed(id);

-- Create "union" views for the _open + _closed
CREATE VIEW moderation_all AS
    SELECT * FROM moderation_open
    UNION ALL
    SELECT * FROM moderation_closed;

CREATE VIEW moderation_note_all AS
    SELECT * FROM moderation_note_open
    UNION ALL
    SELECT * FROM moderation_note_closed;

CREATE VIEW vote_all AS
    SELECT * FROM vote_open
    UNION ALL
    SELECT * FROM vote_closed;

CREATE OR REPLACE FUNCTION after_update_moderation_open () RETURNS TRIGGER AS '
begin

    if (OLD.status IN (1,8) and NEW.status NOT IN (1,8)) -- STATUS_OPEN, STATUS_TOBEDELETED
    then
        -- Create moderation_closed record
        INSERT INTO moderation_closed SELECT * FROM moderation_open WHERE id = NEW.id;
        -- and update the closetime
        UPDATE moderation_closed SET closetime = NOW() WHERE id = NEW.id;

        -- Copy notes
        INSERT INTO moderation_note_closed
            SELECT * FROM moderation_note_open
            WHERE moderation = NEW.id;

        -- Copy votes
        INSERT INTO vote_closed
            SELECT * FROM vote_open
            WHERE moderation = NEW.id;

        -- Delete the _open records
        DELETE FROM vote_open WHERE moderation = NEW.id;
        DELETE FROM moderation_note_open WHERE moderation = NEW.id;
        DELETE FROM moderation_open WHERE id = NEW.id;
    end if;

    return NEW;
end;
' LANGUAGE 'plpgsql';
--'--

CREATE TRIGGER a_upd_moderation_open AFTER UPDATE ON moderation_open
    FOR EACH ROW EXECUTE PROCEDURE after_update_moderation_open();

ALTER TABLE moderator_subscribe_artist
    ALTER COLUMN lastmodsent DROP DEFAULT;

COMMIT;

-- All done.  Optimise the new tables
VACUUM ANALYZE moderation_open;
VACUUM ANALYZE moderation_note_open;
VACUUM ANALYZE vote_open;
VACUUM ANALYZE moderation_closed;
VACUUM ANALYZE moderation_note_closed;
VACUUM ANALYZE vote_closed;

-- vi: set ts=4 sw=4 et :
