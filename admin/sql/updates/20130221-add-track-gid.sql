\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE track ADD COLUMN gid UUID;
UPDATE track SET gid = generate_uuid_v4();

COMMIT; -- execute triggers.

BEGIN;

ALTER TABLE track ALTER COLUMN gid SET not null;

CREATE TABLE track_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references track.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE track_gid_redirect
    ADD CONSTRAINT track_gid_redirect_pkey
    PRIMARY KEY (gid);

ALTER TABLE track_gid_redirect
   ADD CONSTRAINT track_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES track(id);

--CREATE TRIGGER "reptg_track_gid_redirect"
--   AFTER INSERT OR DELETE OR UPDATE ON "track_gid_redirect"
--   FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

COMMIT;

-- vi: set ts=4 sw=4 et :
