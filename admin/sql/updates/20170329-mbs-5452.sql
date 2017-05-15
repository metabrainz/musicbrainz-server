\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE work_language (
    work            INTEGER NOT NULL,
    language        INTEGER NOT NULL,
    edits_pending   INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created         TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO work_language (work, language)
    (SELECT id, language FROM work WHERE language IS NOT NULL);

ALTER TABLE work_language
    ADD CONSTRAINT work_language_pkey
    PRIMARY KEY (work, language);

ALTER TABLE work DROP COLUMN language;

COMMIT;
