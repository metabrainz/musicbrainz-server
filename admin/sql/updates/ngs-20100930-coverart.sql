BEGIN;

CREATE TABLE release_coverart
(
    id INTEGER NOT NULL,
    coverfetched TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    coverarturl VARCHAR(255)
);

INSERT INTO release_coverart (id, coverfetched, coverarturl)
    SELECT id, coverfetched, coverarturl FROM release_meta
     WHERE coverarturl IS NOT NULL;

ALTER TABLE release_meta DROP coverfetched;
ALTER TABLE release_meta DROP coverarturl;

COMMIT;
