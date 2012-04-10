BEGIN;

CREATE TABLE iswc (
    id SERIAL NOT NULL,
    work INTEGER NOT NULL,
    iswc CHARACTER(15) CHECK (iswc ~ '^T-?\d{3}.?\d{3}.?\d{3}[-.]?\d$'),
    source SMALLINT,
    edits_pending INTEGER NOT NULL DEFAULT 0,
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

INSERT INTO iswc (work, iswc) SELECT id, iswc FROM work WHERE iswc IS NOT NULL;

ALTER TABLE work DROP COLUMN iswc;

ALTER TABLE iswc ADD PRIMARY KEY (id);
ALTER TABLE iswc ADD CONSTRAINT iswc_work_fkey FOREIGN KEY (work) REFERENCES work (id);

CREATE INDEX iswc_idx_work ON iswc (work);
CREATE UNIQUE INDEX iswc_idx_iswc ON iswc (iswc, work);

COMMIT;
