-- Abstract: add single-column integer primary keys to currentstat, historicalstat

\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE tmp_currentstat AS SELECT * FROM currentstat;
CREATE TABLE tmp_historicalstat AS SELECT * FROM historicalstat;
DROP TABLE currentstat;
DROP TABLE historicalstat;

CREATE TABLE currentstat
(
        id              SERIAL,
        name            VARCHAR(100) NOT NULL,
        value           INTEGER NOT NULL,
        lastupdated     TIMESTAMP WITH TIME ZONE
);

CREATE TABLE historicalstat
(
        id              SERIAL,
        name            VARCHAR(100) NOT NULL,
        value           INTEGER NOT NULL,
        snapshotdate    DATE NOT NULL
);

INSERT INTO currentstat (name, value, lastupdated) SELECT * FROM tmp_currentstat;
INSERT INTO historicalstat (name, value, snapshotdate) SELECT * FROM tmp_historicalstat;
DROP TABLE tmp_currentstat;
DROP TABLE tmp_historicalstat;

ALTER TABLE currentstat ADD CONSTRAINT currentstat_pkey PRIMARY KEY (id);
ALTER TABLE historicalstat ADD CONSTRAINT historicalstat_pkey PRIMARY KEY (id);

CREATE INDEX currentstat_name ON currentstat (name);
CREATE INDEX historicalstat_date ON historicalstat (snapshotdate);
CREATE INDEX historicalstat_name_snapshotdate ON historicalstat (name, snapshotdate);

COMMIT;

-- vi: set ts=4 sw=4 et :
