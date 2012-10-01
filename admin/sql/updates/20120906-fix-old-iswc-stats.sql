BEGIN;
UPDATE statistic SET name = 'count.work.has_iswc' WHERE name = 'count.iswc.all' AND date_collected > '2012-05-15';
COMMIT;
