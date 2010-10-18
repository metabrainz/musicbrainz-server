\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE artist ADD COLUMN ipicode VARCHAR(11);
ALTER TABLE label ADD COLUMN ipicode VARCHAR(11);

CREATE INDEX artist_idx_ipicode ON artist (ipicode);
CREATE INDEX label_idx_ipicode ON label (ipicode);

COMMIT;
