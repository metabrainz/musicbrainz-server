BEGIN;

UPDATE release_group_meta SET first_release_date_year = expected.date_year,
                              first_release_date_month = expected.date_month,
                              first_release_date_day = expected.date_day
  FROM (
    SELECT release_group, date_year, date_month, date_day,
      row_number() OVER (
        PARTITION BY release_group
        ORDER BY
          date_year NULLS LAST,
          date_month NULLS LAST,
          date_day NULLS LAST
      )
    FROM (
      SELECT release, date_year, date_month, date_day
      FROM release_country
      UNION
      SELECT release, date_year, date_month, date_day
      FROM release_unknown_country
    ) b
    RIGHT JOIN release ON release.id = b.release
  ) AS expected
WHERE release_group_meta.id = expected.release_group
  AND (first_release_date_year IS DISTINCT FROM expected.date_year
         OR first_release_date_month IS DISTINCT FROM expected.date_month
         OR first_release_date_day IS DISTINCT FROM expected.date_day)
  AND row_number = 1;

COMMIT;
