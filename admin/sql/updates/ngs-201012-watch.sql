BEGIN;

CREATE TABLE editor_watch_preferences
(
    editor INTEGER NOT NULL, -- PK, references editor.id CASCADE
    notify_via_email BOOLEAN NOT NULL DEFAULT TRUE,
    notification_timeframe INTERVAL NOT NULL DEFAULT '1 week',
    last_checked TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE editor_watch_artist
(
    artist INTEGER NOT NULL, -- PK, references artist.id CASCADE
    editor INTEGER NOT NULL  -- PK, references editor.id CASCADE
);

CREATE TABLE editor_watch_release_group_type
(
    editor INTEGER NOT NULL, -- PK, references editor.id CASCADE
    release_group_type INTEGER NOT NULL -- PK, references release_group_type.id
);

CREATE TABLE editor_watch_release_status
(
    editor INTEGER NOT NULL, -- PK, references editor.id CASCADE
    release_status INTEGER NOT NULL -- PK, references release_status.id
);

INSERT INTO editor_watch_preferences
    (editor) SELECT id FROM editor;

ALTER TABLE editor_watch_artist ADD CONSTRAINT editor_watch_artist_pkey PRIMARY KEY (artist, editor);
ALTER TABLE editor_watch_preferences ADD CONSTRAINT editor_watch_preferences_pkey PRIMARY KEY (editor);
ALTER TABLE editor_watch_release_group_type ADD CONSTRAINT editor_watch_release_group_type_pkey PRIMARY KEY (editor, release_group_type);
ALTER TABLE editor_watch_release_status ADD CONSTRAINT editor_watch_release_status_pkey PRIMARY KEY (editor, release_status);

ALTER TABLE editor_watch_artist
   ADD CONSTRAINT editor_watch_artist_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id)
   ON DELETE CASCADE;

ALTER TABLE editor_watch_artist
   ADD CONSTRAINT editor_watch_artist_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id)
   ON DELETE CASCADE;

ALTER TABLE editor_watch_preferences
   ADD CONSTRAINT editor_watch_preferences_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id)
   ON DELETE CASCADE;

ALTER TABLE editor_watch_release_group_type
   ADD CONSTRAINT editor_watch_release_group_type_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id)
   ON DELETE CASCADE;

ALTER TABLE editor_watch_release_group_type
   ADD CONSTRAINT editor_watch_release_group_type_fk_release_group_type
   FOREIGN KEY (release_group_type)
   REFERENCES release_group_type(id);

ALTER TABLE editor_watch_release_status
   ADD CONSTRAINT editor_watch_release_status_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id)
   ON DELETE CASCADE;

ALTER TABLE editor_watch_release_status
   ADD CONSTRAINT editor_watch_release_status_fk_release_status
   FOREIGN KEY (release_status)
   REFERENCES release_status(id);


COMMIT;
