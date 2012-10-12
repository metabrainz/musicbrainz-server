\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE log_statistic
(
    name                TEXT NOT NULL, -- PK
    category            TEXT NOT NULL, -- PK
    timestamp           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), -- PK
    data                TEXT NOT NULL -- JSON data
);

ALTER TABLE log_statistic ADD CONSTRAINT log_statistic_pkey PRIMARY KEY (name, category, timestamp);
ALTER TABLE log_statistic SET SCHEMA statistics;

COMMIT;
