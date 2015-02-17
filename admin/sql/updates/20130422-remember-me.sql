BEGIN;

CREATE TABLE editor_remember_me (
    editor integer NOT NULL REFERENCES editor (id),
    token uuid NOT NULL DEFAULT generate_uuid_v4(),
    allocated timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (editor, token)
);

COMMIT;
