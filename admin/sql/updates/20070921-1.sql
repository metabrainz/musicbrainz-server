\set ON_ERROR_STOP 1

BEGIN;

UPDATE albummeta SET puids = (
    SELECT COUNT(puidjoin.*)
           FROM puidjoin, albumjoin
           WHERE albummeta.id = albumjoin.album
           AND albumjoin.track = puidjoin.track
);

COMMIT;
