-- Abstract: Subscription to editor.

\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE editor_subscribe_editor
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references moderator (the one who has subscribed)
    subscribededitor    INTEGER NOT NULL, -- references moderator (the one being subscribed)
    lasteditsent        INTEGER NOT NULL  -- weakly references moderation
);

ALTER TABLE editor_subscribe_editor ADD CONSTRAINT editor_subscribe_editor_pkey PRIMARY KEY (id);
CREATE UNIQUE INDEX editor_subscribe_editor_editor_key ON editor_subscribe_editor (editor, subscribededitor);

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
