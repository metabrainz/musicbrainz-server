BEGIN;

SET search_path = 'musicbrainz_statistics';

CREATE TABLE statistic
(
    id                  SERIAL,
    name                VARCHAR(100) NOT NULL,
    value               INTEGER NOT NULL,
    date_collected      date NOT NULL DEFAULT NOW()
);

CREATE TABLE statistic_event (
    date DATE NOT NULL CHECK (date >= '2000-01-01'), -- PK
    title TEXT NOT NULL,
    link TEXT NOT NULL,
    description TEXT NOT NULL
);

COMMIT;
