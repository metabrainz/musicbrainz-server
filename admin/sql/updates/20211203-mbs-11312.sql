\set ON_ERROR_STOP 1

BEGIN;

DO $$
BEGIN
  PERFORM 1 FROM pg_type
  WHERE typname = 'edit_note_status';

  IF NOT FOUND THEN
    CREATE TYPE edit_note_status AS ENUM ('deleted', 'edited');
  END IF;
END
$$;

CREATE TABLE edit_note_change
(
    id                  SERIAL, -- PK
    status              edit_note_status,
    edit_note           INTEGER NOT NULL, -- references edit_note.id
    change_editor       INTEGER NOT NULL, -- references editor.id
    change_time         TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    old_note            TEXT NOT NULL,
    new_note            TEXT NOT NULL,
    reason              TEXT NOT NULL DEFAULT ''
);

-- Primary keys

ALTER TABLE edit_note_change ADD CONSTRAINT edit_note_change_pkey PRIMARY KEY (id);

-- Indexes

CREATE INDEX edit_note_change_idx_edit_note ON edit_note_change (edit_note);

COMMIT;
