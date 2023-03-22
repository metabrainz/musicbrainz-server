\set ON_ERROR_STOP 1

BEGIN;

-- Update the release update function to reset dates when status set to/from cancelled
CREATE OR REPLACE FUNCTION a_upd_release() RETURNS trigger AS $$
BEGIN
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF (
        NEW.status IS DISTINCT FROM OLD.status AND
        (NEW.status = 6 OR OLD.status = 6)
    ) THEN
        PERFORM set_release_first_release_date(NEW.id);

        -- avoid executing it twice as this will be executed a few lines below if RG changes
        IF NEW.release_group = OLD.release_group THEN
            PERFORM set_release_group_first_release_date(NEW.release_group);
        END IF;

        PERFORM set_releases_recordings_first_release_dates(ARRAY[NEW.id]);
    END IF;
    IF NEW.release_group != OLD.release_group THEN
        -- release group is changed, decrement release_count in the original RG, increment in the new one
        UPDATE release_group_meta SET release_count = release_count - 1 WHERE id = OLD.release_group;
        UPDATE release_group_meta SET release_count = release_count + 1 WHERE id = NEW.release_group;
        PERFORM set_release_group_first_release_date(OLD.release_group);
        PERFORM set_release_group_first_release_date(NEW.release_group);
    END IF;
    IF (
        NEW.status IS DISTINCT FROM OLD.status OR
        NEW.release_group != OLD.release_group OR
        NEW.artist_credit != OLD.artist_credit
    ) THEN
        INSERT INTO artist_release_group_pending_update
        VALUES (NEW.release_group), (OLD.release_group);
    END IF;
    IF (
        NEW.barcode IS DISTINCT FROM OLD.barcode OR
        NEW.name != OLD.name OR
        NEW.artist_credit != OLD.artist_credit
    ) THEN
        INSERT INTO artist_release_pending_update VALUES (OLD.id);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- Update the release dates function to ignore cancelled releases
CREATE OR REPLACE FUNCTION get_release_first_release_date_rows(condition TEXT)
RETURNS SETOF release_first_release_date AS $$
BEGIN
    RETURN QUERY EXECUTE '
        SELECT DISTINCT ON (release) release,
            date_year AS year,
            date_month AS month,
            date_day AS day
        FROM (
            SELECT release, date_year, date_month, date_day FROM release_country
            WHERE (date_year IS NOT NULL OR date_month IS NOT NULL OR date_day IS NOT NULL)
            UNION ALL
            SELECT release, date_year, date_month, date_day FROM release_unknown_country
        ) all_dates
        WHERE ' || condition ||
        ' AND NOT EXISTS (
          SELECT TRUE
            FROM release
           WHERE release.id = all_dates.release
             AND status = 6
        )
        ORDER BY release, year NULLS LAST, month NULLS LAST, day NULLS LAST';
END;
$$ LANGUAGE 'plpgsql' STRICT;

-- Delete rows already in release_first_release_date for cancelled releases
DELETE FROM release_first_release_date
WHERE release IN (
  SELECT id
    FROM release
   WHERE status = 6
);

-- Rerun set_release_group_first_release_date for release groups with cancelled releases
SELECT set_release_group_first_release_date(release_group) FROM (
  SELECT DISTINCT release_group
    FROM release
   WHERE status = 6
) rgs_with_cancelled_releases;

-- Rerun set_releases_recordings_first_release_dates for cancelled releases
SELECT set_releases_recordings_first_release_dates(array_agg(id))
  FROM release
 WHERE status = 6;

COMMIT;
