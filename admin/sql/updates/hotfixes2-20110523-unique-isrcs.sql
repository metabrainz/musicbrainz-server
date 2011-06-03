BEGIN;

DELETE FROM isrc
WHERE id IN (
    SELECT id
      FROM (SELECT row_number() OVER (partition by isrc, recording), id FROM isrc) s
     WHERE s.row_number > 1
);

CREATE UNIQUE INDEX isrc_idx_isrc_recording ON isrc (isrc, recording);

COMMIT;
