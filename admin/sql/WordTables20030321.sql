\set ON_ERROR_STOP 1
BEGIN;

-- Unnecessary duplicate indexes
DROP INDEX artistwords_wordidindex;
DROP INDEX albumwords_wordidindex;
DROP INDEX trackwords_wordidindex;

SELECT *
INTO TEMPORARY TABLE tmp_wordlist
FROM wordlist;

DROP TABLE wordlist;

CREATE TABLE wordlist
(
   id serial primary key,
   word varchar(255) not null,
   artistusecount SMALLINT NOT NULL DEFAULT 0,
   albumusecount SMALLINT NOT NULL DEFAULT 0,
   trackusecount SMALLINT NOT NULL DEFAULT 0,
   UNIQUE(word)
);

TRUNCATE TABLE artistwords;
TRUNCATE TABLE albumwords;
TRUNCATE TABLE trackwords;
--INSERT INTO wordlist (id, word) SELECT * FROM tmp_wordlist;

COMMIT;

-- vi: set et :
