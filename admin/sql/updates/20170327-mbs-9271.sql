\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE old_editor_name (
    name    VARCHAR(64) NOT NULL
);

CREATE UNIQUE INDEX old_editor_name_idx_name ON old_editor_name (LOWER(name));

CREATE OR REPLACE FUNCTION check_editor_name() RETURNS trigger AS $$
BEGIN
    IF (SELECT 1 FROM old_editor_name WHERE lower(name) = lower(NEW.name))
    THEN
        RAISE EXCEPTION 'Attempt to use a previously-used editor name.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
