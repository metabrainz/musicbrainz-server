BEGIN;

ALTER TABLE editor ADD COLUMN birth_date DATE;
ALTER TABLE editor ADD COLUMN gender INTEGER;
ALTER TABLE editor ADD COLUMN country INTEGER;

ALTER TABLE editor ADD CONSTRAINT editor_fk_gender FOREIGN KEY (gender) REFERENCES gender (id);
ALTER TABLE editor ADD CONSTRAINT editor_fk_country FOREIGN KEY (country) REFERENCES country (id);

CREATE TYPE FLUENCY AS ENUM ('basic', 'intermediate', 'advanced', 'native');

CREATE TABLE editor_language (
    editor INTEGER NOT NULL REFERENCES editor (id),
    language INTEGER NOT NULL REFERENCES language (id),
    fluency FLUENCY NOT NULL,
    PRIMARY KEY (editor, language)
);

CREATE INDEX editor_language_idx_language ON editor_language (language);

COMMIT;
