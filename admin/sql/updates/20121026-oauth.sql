BEGIN;


CREATE TABLE application
(
    id                  SERIAL,
    owner               INTEGER NOT NULL, -- references editor.id
    name                TEXT NOT NULL,
    oauth_id            TEXT NOT NULL,
    oauth_secret        TEXT NOT NULL,
    oauth_redirect_uri  TEXT
);

CREATE TABLE editor_oauth_token
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    application         INTEGER NOT NULL, -- references application.id
    authorization_code  TEXT,
    refresh_token       TEXT,
    access_token        TEXT,
    mac_key             TEXT,
    mac_time_diff       INTEGER,
    expire_time         TIMESTAMP WITH TIME ZONE NOT NULL,
    scope               INTEGER NOT NULL DEFAULT 0,
    granted             TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


ALTER TABLE application ADD CONSTRAINT application_pkey PRIMARY KEY (id);
ALTER TABLE editor_oauth_token ADD CONSTRAINT editor_oauth_token_pkey PRIMARY KEY (id);


CREATE INDEX application_idx_owner ON application (owner);
CREATE UNIQUE INDEX application_idx_oauth_id ON application (oauth_id);

CREATE INDEX editor_oauth_token_idx_editor ON editor_oauth_token (editor);
CREATE UNIQUE INDEX editor_oauth_token_idx_access_token ON editor_oauth_token (access_token);
CREATE UNIQUE INDEX editor_oauth_token_idx_refresh_token ON editor_oauth_token (refresh_token);


INSERT INTO application (owner, name, oauth_id, oauth_secret)
   VALUES (1, 'MusicBrainz Test Application', 'uTuPnUfMRQPx8HBnHf22eg', '7Fjfp0ZBr1KtDRbnfVdmIw');

SELECT setval('application_id_seq', (SELECT MAX(id) FROM application));
SELECT setval('editor_oauth_token_id_seq', (SELECT MAX(id) FROM editor_oauth_token));

COMMIT;
