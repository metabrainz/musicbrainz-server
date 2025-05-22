\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION set_release_group_first_release_date(release_group_id INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE release_group_meta SET first_release_date_year = first.year,
                                  first_release_date_month = first.month,
                                  first_release_date_day = first.day
      FROM (
        SELECT rd.year, rd.month, rd.day
        FROM release_group
        LEFT JOIN release ON release.release_group = release_group.id
        LEFT JOIN release_first_release_date rd ON (rd.release = release.id)
        WHERE release_group.id = release_group_id
        ORDER BY
          rd.year NULLS LAST,
          rd.month NULLS LAST,
          rd.day NULLS LAST
        LIMIT 1
      ) AS first
    WHERE id = release_group_id;
    INSERT INTO artist_release_group_pending_update VALUES (release_group_id);
END;
$$ LANGUAGE 'plpgsql';

CREATE TEMPORARY TABLE tmp_release_first_release_date_2025_q2 (
    release     INTEGER NOT NULL PRIMARY KEY,
    year        SMALLINT,
    month       SMALLINT,
    day         SMALLINT
) ON COMMIT DROP;

INSERT INTO tmp_release_first_release_date_2025_q2
    SELECT * FROM get_release_first_release_date_rows('TRUE');

UPDATE release_group_meta SET first_release_date_year = first.year,
                              first_release_date_month = first.month,
                              first_release_date_day = first.day
  FROM (
    SELECT DISTINCT ON (release_group.id)
        release_group.id AS release_group, rd.year, rd.month, rd.day
    FROM release_group
    LEFT JOIN release ON release.release_group = release_group.id
    LEFT JOIN tmp_release_first_release_date_2025_q2 rd ON (rd.release = release.id)
    ORDER BY
      release_group.id,
      rd.year NULLS LAST,
      rd.month NULLS LAST,
      rd.day NULLS LAST
  ) AS first
WHERE id = first.release_group
  AND (
    first_release_date_year IS DISTINCT FROM first.year
    OR first_release_date_month IS DISTINCT FROM first.month
    OR first_release_date_day IS DISTINCT FROM first.day
  );

-- Mirrors have a `a_upd_release_group_meta_mirror` trigger which inserts
-- updated `release_group_meta` IDs into `artist_release_group_pending_update`,
-- which in turn causes the associated entries in `artist_release_group`
-- to be updated. That should be a no-op here, because the schema 30 upgrade
-- already truncates `artist_release_group` (via dropping and recreating it)
-- before this runs; but clear it anyway to avoid a pointless calculation in
-- the `apply_artist_release_group_pending_updates` function.
TRUNCATE artist_release_group_pending_update;

COMMIT;
