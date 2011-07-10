BEGIN;

ALTER TABLE tracklist_index ADD CONSTRAINT tracklist_index_pkey PRIMARY KEY (tracklist);
CREATE INDEX tracklist_index_idx ON tracklist_index USING gist (toc);

CREATE TRIGGER "reptg_tracklist_index"
AFTER INSERT OR DELETE OR UPDATE ON "tracklist_index"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

COMMIT;
