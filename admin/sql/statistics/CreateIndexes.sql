SET search_path = 'statistics';

\set ON_ERROR_STOP 1
BEGIN;

CREATE INDEX statistic_name ON statistic (name);
CREATE UNIQUE INDEX statistic_name_date_collected ON statistic (name, date_collected);

COMMIT;

-- vi: set ts=4 sw=4 et :
