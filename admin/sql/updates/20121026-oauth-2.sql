BEGIN;

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

COMMIT;
