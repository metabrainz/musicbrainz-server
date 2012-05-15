BEGIN;

ALTER TABLE editor ADD CONSTRAINT editor_fk_gender FOREIGN KEY (gender) REFERENCES gender (id);
ALTER TABLE editor ADD CONSTRAINT editor_fk_country FOREIGN KEY (country) REFERENCES country (id);

ALTER TABLE editor_language ADD CONSTRAINT editor_language_fk_editor
FOREIGN KEY (editor) REFERENCES editor (id);

ALTER TABLE editor_language ADD CONSTRAINT editor_language_fk_language
FOREIGN KEY (language) REFERENCES language (id);

COMMIT;
