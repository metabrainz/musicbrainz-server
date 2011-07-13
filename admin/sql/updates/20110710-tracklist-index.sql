BEGIN;

DROP TABLE tracklist_index;

CREATE TABLE tracklist_index
(
    tracklist           INTEGER, -- PK
    tracks              INTEGER,
    toc                 CUBE
);

INSERT INTO tracklist_index (tracklist, tracks, toc)
    SELECT s.tracklist, count(s.length), create_cube_from_durations(array_accum(s.length)) 
      FROM 
          (
           SELECT t.tracklist, t.length
           FROM (
                 SELECT tracklist FROM track t, recording r
                  WHERE t.recording = r.id 
               GROUP BY tracklist
                 HAVING every(r.length != 0)
                ) tr, track t, recording r
           WHERE tr.tracklist = t.tracklist AND t.recording = r.id
           ORDER BY t.tracklist, t.position
          ) AS s 
    GROUP BY s.tracklist;

ALTER TABLE tracklist_index ADD CONSTRAINT tracklist_index_pkey PRIMARY KEY (tracklist);
CREATE INDEX tracklist_index_idx ON tracklist_index USING gist (toc);

CREATE TRIGGER "reptg_tracklist_index"
AFTER INSERT OR DELETE OR UPDATE ON "tracklist_index"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

COMMIT;
