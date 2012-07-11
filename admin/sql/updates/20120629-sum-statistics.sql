BEGIN;

UPDATE statistic stat SET
  value = (SELECT value FROM statistic WHERE name = 'count.ipi.artist' AND date_collected = stat.date_collected) +
          (SELECT value FROM statistic WHERE name = 'count.ipi.label' AND date_collected = stat.date_collected)
WHERE name = 'count.ipi';

UPDATE statistic stat SET
  value = (SELECT value FROM statistic WHERE name = 'count.release' AND date_collected = stat.date_collected) -
          (SELECT value FROM statistic WHERE name = 'count.release.various' AND date_collected = stat.date_collected)
WHERE name = 'count.release.nonvarious';

UPDATE statistic stat SET
  value = COALESCE((SELECT value FROM statistic WHERE name = 'count.tag.raw.artist' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.tag.raw.label' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.tag.raw.release' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.tag.raw.releasegroup' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.tag.raw.work' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.tag.raw.recording' AND date_collected = stat.date_collected), 0)
WHERE name = 'count.tag.raw';

UPDATE statistic stat SET
  value = COALESCE((SELECT value FROM statistic WHERE name = 'count.rating.artist' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.rating.label' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.rating.releasegroup' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.rating.work' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.rating.recording' AND date_collected = stat.date_collected), 0)
WHERE name = 'count.rating';

UPDATE statistic stat SET
  value = COALESCE((SELECT value FROM statistic WHERE name = 'count.rating.raw.artist' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.rating.raw.label' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.rating.raw.releasegroup' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.rating.raw.work' AND date_collected = stat.date_collected), 0) +
          COALESCE((SELECT value FROM statistic WHERE name = 'count.rating.raw.recording' AND date_collected = stat.date_collected), 0)
WHERE name = 'count.rating.raw';

COMMIT;
