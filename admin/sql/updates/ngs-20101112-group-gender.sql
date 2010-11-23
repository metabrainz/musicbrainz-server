
\set ON_ERROR_STOP 1
BEGIN;

UPDATE artist SET gender = NULL WHERE type = 2;

ALTER TABLE artist ADD CONSTRAINT artist_gender
    CHECK ( (type = 2 AND gender IS NULL) OR (type != 2) );

COMMIT;
