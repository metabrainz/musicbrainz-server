BEGIN;


DROP TABLE editor_oauth_token;
DROP TABLE application;


CREATE TABLE application
(
    id                  SERIAL,
    owner               INTEGER NOT NULL, -- references editor.id
    name                TEXT NOT NULL,
    oauth_id            TEXT NOT NULL,
    oauth_secret        TEXT NOT NULL,
    oauth_redirect_uri  TEXT NOT NULL,
    oauth_confidential  BOOLEAN NOT NULL
);

CREATE TABLE editor_oauth_token
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    application         INTEGER NOT NULL, -- references application.id
    authorization_code  TEXT,
    refresh_token       TEXT,
    access_token        TEXT,
    secret              TEXT,
    expire_time         TIMESTAMP WITH TIME ZONE NOT NULL,
    scope_profile       BOOLEAN NOT NULL DEFAULT FALSE,
    scope_tags          BOOLEAN NOT NULL DEFAULT FALSE,
    scope_ratings       BOOLEAN NOT NULL DEFAULT FALSE
);


ALTER TABLE application ADD CONSTRAINT application_pkey PRIMARY KEY (id);
ALTER TABLE editor_oauth_token ADD CONSTRAINT editor_oauth_token_pkey PRIMARY KEY (id);


CREATE UNIQUE INDEX application_idx_oauth_id ON application (oauth_id);
CREATE UNIQUE INDEX editor_oauth_token_idx_access_token ON editor_oauth_token (access_token);
CREATE UNIQUE INDEX editor_oauth_token_idx_refresh_token ON editor_oauth_token (refresh_token);


ALTER TABLE application
   ADD CONSTRAINT application_fk_owner
   FOREIGN KEY (owner)
   REFERENCES editor(id);

ALTER TABLE editor_oauth_token
   ADD CONSTRAINT editor_oauth_token_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_oauth_token
   ADD CONSTRAINT editor_oauth_token_fk_application
   FOREIGN KEY (application)
   REFERENCES application(id);


INSERT INTO application (owner, name, oauth_id, oauth_secret, oauth_redirect_uri, oauth_confidential)
   VALUES (1, 'MusicBrainz Picard', 's6BhdRkqt3', '7Fjfp0ZBr1KtDRbnfVdmIw', 'urn:ietf:wg:oauth:2.0:oob', false);

COMMIT;
