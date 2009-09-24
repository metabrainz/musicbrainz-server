BEGIN;

CREATE AGGREGATE array_accum (basetype = anyelement, sfunc = array_append, stype = anyarray, initcond = '{}');

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

DROP AGGREGATE array_accum (anyelement);

COMMIT;
