-- Abstract: create FKs from moderationnote to moderation / moderator

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE moderationnote
    ADD CONSTRAINT moderationnote_fk_moderation
    FOREIGN KEY (modid)
    REFERENCES moderation(id);

-- There are three rows in moderationnote where uid==0
-- These look like old test data rows
DELETE FROM moderationnote WHERE uid = 0;

ALTER TABLE moderationnote
    ADD CONSTRAINT moderationnote_fk_moderator
    FOREIGN KEY (uid)
    REFERENCES moderator(id);

COMMIT;

-- vi: set ts=4 sw=4 et :
