\set ON_ERROR_STOP 1
BEGIN;

-- Unnecessary duplicate indexes
DROP INDEX artistwords_wordidindex;
DROP INDEX albumwords_wordidindex;
DROP INDEX trackwords_wordidindex;

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

COMMIT;

TRUNCATE TABLE artistwords;
TRUNCATE TABLE albumwords;
TRUNCATE TABLE trackwords;

-- vi: set et :
