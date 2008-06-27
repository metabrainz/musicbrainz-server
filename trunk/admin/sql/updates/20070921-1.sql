\set ON_ERROR_STOP 1

BEGIN;

-- Fix the PUID meta counts 

UPDATE albummeta SET puids = (
    SELECT COUNT(puidjoin.*)
           FROM puidjoin, albumjoin
           WHERE albummeta.id = albumjoin.album
           AND albumjoin.track = puidjoin.track
);

-- Change the moderation table PrevValue field to TEXT

DROP VIEW moderation_all;

ALTER TABLE moderation_open ALTER prevvalue TYPE TEXT;
ALTER TABLE moderation_closed ALTER prevvalue TYPE TEXT;

CREATE VIEW moderation_all AS
    SELECT * FROM moderation_open
    UNION ALL
    SELECT * FROM moderation_closed;


COMMIT;
