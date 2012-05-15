-- MBS-2532, Allow more than one IPI per artist
\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE artist_ipi
(
    artist              INTEGER NOT NULL,
    ipi                 CHAR(11) NOT NULL CHECK (ipi ~ E'^\\d{11}$'),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (artist, ipi)
);

CREATE TABLE label_ipi
(
    label               INTEGER NOT NULL,
    ipi                 CHAR(11) NOT NULL CHECK (ipi ~ E'^\\d{11}$'),
    edits_pending       INTEGER NOT NULL DEFAULT 0 CHECK (edits_pending >= 0),
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (label, ipi)
);

INSERT INTO artist_ipi (artist, ipi) SELECT id, ipi_code FROM artist WHERE ipi_code IS NOT NULL;
INSERT INTO label_ipi (label, ipi) SELECT id, ipi_code FROM label WHERE ipi_code IS NOT NULL;

ALTER TABLE artist DROP COLUMN ipi_code;
ALTER TABLE label DROP COLUMN ipi_code;

COMMIT;
