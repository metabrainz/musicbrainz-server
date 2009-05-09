BEGIN;

CREATE TABLE language
(
    id                 SERIAL,
    isocode_3t         CHAR(3) NOT NULL, -- ISO 639-2 (T)
    isocode_3b         CHAR(3) NOT NULL, -- ISO 639-2 (B)
    isocode_2          CHAR(2), -- ISO 639
    name               VARCHAR(100) NOT NULL,
    frequency          INTEGER NOT NULL DEFAULT 0
);

ALTER TABLE language ADD CONSTRAINT language_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX language_idx_isocode_3b ON language (isocode_3b);
CREATE UNIQUE INDEX language_idx_isocode_3t ON language (isocode_3t);
CREATE UNIQUE INDEX language_idx_isocode_2 ON language (isocode_2);

COMMIT;
