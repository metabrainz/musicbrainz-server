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

CREATE OR REPLACE VIEW editor_sanitized AS
    SELECT (sanitize_editor(editor)).*
    FROM editor;

COMMIT;
