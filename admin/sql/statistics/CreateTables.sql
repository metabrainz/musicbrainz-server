BEGIN;

SET search_path = 'statistics';

CREATE TABLE statistic ( -- replicate
    id                  SERIAL,
    name                VARCHAR(100) NOT NULL,
    value               INTEGER NOT NULL,
    date_collected      date NOT NULL DEFAULT NOW()
);

CREATE TABLE statistic_event ( -- replicate
    date DATE NOT NULL CHECK (date >= '2000-01-01'), -- PK
    title TEXT NOT NULL,
    link TEXT NOT NULL,
    description TEXT NOT NULL
);

COMMIT;
