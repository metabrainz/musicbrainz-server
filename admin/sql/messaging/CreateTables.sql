\set ON_ERROR_STOP 1

BEGIN;

SET search_path = 'messaging';

CREATE TABLE edit_note_thanks (
  edit_note           INTEGER NOT NULL, -- PK, references edit_note.id
  thanker             INTEGER NOT NULL, -- PK, references editor.id
  created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE edit_thanks (
  edit                INTEGER NOT NULL, -- PK, references edit.id
  thanker             INTEGER NOT NULL, -- PK, references editor.id
  created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE hidden_message (
  message             INTEGER NOT NULL, -- PK, references message.id
  editor              INTEGER NOT NULL, -- PK, references editor.id
);

CREATE TABLE message (
  id                  SERIAL, -- PK
  sender              INTEGER NOT NULL, -- references editor.id
  receiver            INTEGER NOT NULL, -- references editor.id
  title               VARCHAR(255),
  text                TEXT,
  parent              INTEGER, -- references message.id
  created             TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read                BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE notification (
  id                  SERIAL, -- PK
  receiver            INTEGER NOT NULL, -- references editor.id
  text                TEXT,
  created             TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read                TIMESTAMP WITH TIME ZONE
);

COMMIT;
