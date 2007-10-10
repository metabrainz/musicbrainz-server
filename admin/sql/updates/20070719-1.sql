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

COMMIT;

-- vi: set ts=4 sw=4 et :
