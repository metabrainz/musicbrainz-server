-- Abstract: Subscription to editor.

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE editor_subscribe_editor
    ADD CONSTRAINT editsubeditor_fk_moderator
    FOREIGN KEY (editor)
    REFERENCES moderator(id);

ALTER TABLE editor_subscribe_editor
    ADD CONSTRAINT editsubeditor_fk_moderator2
    FOREIGN KEY (subscribededitor)
    REFERENCES moderator(id);

COMMIT;

-- vi: set ts=4 sw=4 et :
