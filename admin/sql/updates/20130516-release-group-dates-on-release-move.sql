BEGIN;

CREATE OR REPLACE FUNCTION a_upd_release() RETURNS trigger AS $$
BEGIN
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.release_group != OLD.release_group THEN
        -- release group is changed, decrement release_count in the original RG, increment in the new one
        UPDATE release_group_meta SET release_count = release_count - 1 WHERE id = OLD.release_group;
        UPDATE release_group_meta SET release_count = release_count + 1 WHERE id = NEW.release_group;
        PERFORM set_release_group_first_release_date(OLD.release_group);
        PERFORM set_release_group_first_release_date(NEW.release_group);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

UPDATE release_group_meta SET first_release_date_year = expected.date_year,
                              first_release_date_month = expected.date_month,
                              first_release_date_day = expected.date_day
  FROM (
    SELECT release_group, date_year, date_month, date_day,
      row_number() OVER (
        PARTITION BY release_group
        ORDER BY
          date_year NULLS LAST,
          date_month NULLS FIRST,
          date_day NULLS FIRST
      )
    FROM (
      SELECT release, date_year, date_month, date_day
      FROM release_country
      UNION
      SELECT release, date_year, date_month, date_day
      FROM release_unknown_country
    ) b
    JOIN release ON release.id = b.release
  ) AS expected
WHERE release_group_meta.id = expected.release_group
  AND (first_release_date_year IS DISTINCT FROM expected.date_year
         OR first_release_date_month IS DISTINCT FROM expected.date_month
         OR first_release_date_day IS DISTINCT FROM expected.date_day)
  AND row_number = 1;

COMMIT;
