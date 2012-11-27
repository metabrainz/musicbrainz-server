SET search_path = 'statistics';

SET autocommit TO 'on';

DROP TRIGGER "reptg_statistic" ON "statistic";
DROP TRIGGER "reptg_statistic_event" ON "statistic_event";

-- vi: set ts=4 sw=4 et :
