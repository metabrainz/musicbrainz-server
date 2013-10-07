\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE VIEW release_event AS
    SELECT
        release, date_year, date_month, date_day, country
    FROM (
        SELECT release, date_year, date_month, date_day, country
        FROM release_country
        UNION ALL
        SELECT release, date_year, date_month, date_day, NULL
        FROM release_unknown_country
    ) as q;

COMMIT;

-- vi: set ts=4 sw=4 et :
