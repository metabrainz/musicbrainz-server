BEGIN;

CREATE TABLE editor_remember_me (
    editor integer NOT NULL REFERENCES editor (id),
    token uuid NOT NULL,
    allocated timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (editor, token)
);

COMMIT;
