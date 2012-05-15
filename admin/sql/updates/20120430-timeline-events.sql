\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE statistic_event (
    date DATE NOT NULL CHECK (date >= '2000-01-01'),
    title TEXT NOT NULL,
    link TEXT NOT NULL,
    description TEXT NOT NULL,
    PRIMARY KEY (date)
);

COMMIT;
