\set ON_ERROR_STOP 1

BEGIN;

delete from historicalstat
where name in (
	'count.moderation.perday', 'count.moderation.perweek', 
	'count.vote.perday', 'count.vote.perweek'
);


insert into historicalstat (name, snapshotdate, value)
	select 'count.moderation.perday', opentime::date, count(id) 
	from moderation_all 
	where moderator not in (2,4)		-- skip FREEDB_MODERATOR & MODBOT_MODERATOR
		and opentime::date >= '2003-01-10'
	group by opentime::date;

insert into historicalstat (name, snapshotdate, value)
	select 'count.vote.perday', votetime::date, count(id) 
	from vote_all 
	where vote <> -1					-- excludes Abstain votes
		and votetime::date >= '2003-01-10'
	group by votetime::date;

insert into historicalstat (name, snapshotdate, value)
	SELECT'count.moderation.perweek', b.snapshotdate, sum(a.value)
	FROM historicalstat a, historicalstat b
	WHERE a.name = 'count.moderation.perday' AND b.name = a.name
		AND b.snapshotdate - a.snapshotdate <= 7 AND b.snapshotdate - a.snapshotdate > 0
	GROUP BY b.snapshotdate;

insert into historicalstat (name, snapshotdate, value)
	SELECT'count.vote.perweek', b.snapshotdate, sum(a.value)
	FROM historicalstat a, historicalstat b
	WHERE a.name = 'count.vote.perday' AND b.name = a.name
		AND b.snapshotdate - a.snapshotdate <= 7 AND b.snapshotdate - a.snapshotdate > 0
	GROUP BY b.snapshotdate;

COMMIT;
