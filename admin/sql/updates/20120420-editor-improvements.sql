BEGIN;

ALTER TABLE editor ADD COLUMN birth_date DATE;
ALTER TABLE editor ADD COLUMN gender INTEGER;
ALTER TABLE editor ADD COLUMN country INTEGER;

CREATE TYPE FLUENCY AS ENUM ('basic', 'intermediate', 'advanced', 'native');

CREATE TABLE editor_language (
    editor INTEGER NOT NULL,
    language INTEGER NOT NULL,
    fluency FLUENCY NOT NULL,
    PRIMARY KEY (editor, language)
);

CREATE INDEX editor_language_idx_language ON editor_language (language);

INSERT INTO editor_preference (editor, name, value) SELECT id, 'show_gravatar', 0 FROM editor;

COMMIT;
