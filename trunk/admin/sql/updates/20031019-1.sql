-- Abstract: add automodsaccepted and modsfailed to moderator table
-- Abstract: then fully re-calculate the mod counts for all users

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE moderator ADD COLUMN automodsaccepted INTEGER;
ALTER TABLE moderator ADD COLUMN modsfailed INTEGER;

SELECT  moderator, status, automod, COUNT(*) AS freq
INTO TEMPORARY TABLE tmp_mod_counts
FROM    moderation
WHERE   status > 1
GROUP BY moderator, status, automod;

CREATE INDEX tmp_mod_counts_mod ON tmp_mod_counts (moderator);
CREATE INDEX tmp_mod_counts_sta ON tmp_mod_counts (status);

UPDATE  moderator
SET     modsaccepted = 0,
        automodsaccepted = 0,
        modsrejected = 0,
        modsfailed = 0;

UPDATE  moderator
SET     modsaccepted = t.freq
FROM    (
    SELECT  moderator, SUM(freq) AS freq
    FROM    tmp_mod_counts
    WHERE   status = 2
    AND     automod = 0
    GROUP BY moderator
) t
WHERE   t.moderator = moderator.id;

UPDATE  moderator
SET     automodsaccepted = t.freq
FROM    (
    SELECT  moderator, SUM(freq) AS freq
    FROM    tmp_mod_counts
    WHERE   status = 2
    AND     automod > 0
    GROUP BY moderator
) t
WHERE   t.moderator = moderator.id;

UPDATE  moderator
SET     modsrejected = t.freq
FROM    (
    SELECT  moderator, SUM(freq) AS freq
    FROM    tmp_mod_counts
    WHERE   status = 3
    GROUP BY moderator
) t
WHERE   t.moderator = moderator.id;

UPDATE  moderator
SET     modsfailed = t.freq
FROM    (
    SELECT  moderator, SUM(freq) AS freq
    FROM    tmp_mod_counts
    WHERE   status IN (4,5,6)
    GROUP BY moderator
) t
WHERE   t.moderator = moderator.id;

ALTER TABLE moderator ALTER COLUMN automodsaccepted SET NOT NULL;
ALTER TABLE moderator ALTER COLUMN automodsaccepted SET DEFAULT 0;
ALTER TABLE moderator ALTER COLUMN modsfailed SET NOT NULL;
ALTER TABLE moderator ALTER COLUMN modsfailed SET DEFAULT 0;

COMMIT;

-- vi: set ts=4 sw=4 et :
