BEGIN;

CREATE TABLE script
(
    id                 SERIAL,
    isocode            CHAR(4) NOT NULL, -- ISO 15924
    isonumber          CHAR(3) NOT NULL, -- ISO 15924
    name               VARCHAR(100) NOT NULL,
    frequency          INTEGER NOT NULL DEFAULT 0
);

ALTER TABLE script ADD CONSTRAINT script_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX script_idx_isocode ON script (isocode);

COMMIT;
