\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE iswc (
    id SERIAL NOT NULL,
    work INTEGER NOT NULL,
    iswc CHARACTER(15) CHECK (iswc ~ E'^T-?\\d{3}.?\\d{3}.?\\d{3}[-.]?\\d$'),
    source SMALLINT,
    edits_pending INTEGER NOT NULL DEFAULT 0,
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

INSERT INTO iswc (work, iswc) SELECT id, iswc FROM work WHERE iswc IS NOT NULL;

ALTER TABLE work DROP COLUMN iswc;

ALTER TABLE iswc ADD PRIMARY KEY (id);

CREATE INDEX iswc_idx_work ON iswc (work);
CREATE UNIQUE INDEX iswc_idx_iswc ON iswc (iswc, work);

COMMIT;
