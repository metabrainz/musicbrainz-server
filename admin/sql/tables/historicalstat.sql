\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE historicalstat
(
	name		VARCHAR(100) NOT NULL,
	value		INTEGER NOT NULL,
	snapshotdate	DATE NOT NULL
);

INSERT INTO historicalstat
	SELECT 'count.artist', artists, timestamp
	FROM stats;
INSERT INTO historicalstat
	SELECT 'count.album', albums, timestamp
	FROM stats;
INSERT INTO historicalstat
	SELECT 'count.track', tracks, timestamp
	FROM stats;
INSERT INTO historicalstat
	SELECT 'count.discid', discids, timestamp
	FROM stats;
INSERT INTO historicalstat
	SELECT 'count.trm', trmids, timestamp
	FROM stats;
INSERT INTO historicalstat
	SELECT 'count.moderation', moderations, timestamp
	FROM stats;
INSERT INTO historicalstat
	SELECT 'count.vote', votes, timestamp
	FROM stats;
INSERT INTO historicalstat
	SELECT 'count.moderator', moderators, timestamp
	FROM stats;

CREATE INDEX historicalstat_date on historicalstat (snapshotdate);
CREATE UNIQUE INDEX historicalstat_namedate on historicalstat (name, snapshotdate);

COMMIT;

