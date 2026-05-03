\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION sanitize_editor(e editor) RETURNS editor AS $$
    SELECT ROW(
        e.id,
        e.name,
        0::INTEGER,
        ''::VARCHAR(64),
        NULL::VARCHAR(255),
        NULL::TEXT,
        e.member_since,
        e.email_confirm_date,
        now()::TIMESTAMP WITH TIME ZONE,
        e.last_updated,
        NULL::DATE,
        NULL::INTEGER,
        NULL::INTEGER,
        '{CLEARTEXT}mb'::VARCHAR(128),
        md5(e.name || ':musicbrainz.org:mb')::CHAR(32),
        e.deleted
    )::editor
$$ LANGUAGE sql STABLE PARALLEL SAFE;

-- Adding `STRICT` on `sanitize_editor` would prevent inlining/optimization
-- when called via the `editor_sanitized` view.
CREATE OR REPLACE FUNCTION sanitize_editor_strict(e editor) RETURNS editor AS $$
    SELECT sanitize_editor(e)
$$ LANGUAGE sql STABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sanitize_dbmirror2_editor_data() RETURNS trigger AS $$
BEGIN
    NEW.olddata = row_to_json(sanitize_editor_strict(json_populate_record(NULL::editor, NEW.olddata)));
    NEW.newdata = row_to_json(sanitize_editor_strict(json_populate_record(NULL::editor, NEW.newdata)));
    IF NEW.op = 'u' AND NEW.olddata::JSONB = NEW.newdata::JSONB THEN
        -- Only sanitized columns have changed. No need to log the update.
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW editor_sanitized AS
    SELECT (sanitize_editor(editor)).*
    FROM editor;

COMMIT;
