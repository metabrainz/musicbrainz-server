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

UPDATE release_group_meta SET first_release_date_year = first.year,
                              first_release_date_month = first.month,
                              first_release_date_day = first.day
  FROM (
    SELECT DISTINCT ON (release_group.id)
        release_group.id AS release_group, rd.year, rd.month, rd.day
    FROM release_group
    LEFT JOIN release ON release.release_group = release_group.id
    LEFT JOIN release_first_release_date rd ON (rd.release = release.id)
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

COMMIT;
