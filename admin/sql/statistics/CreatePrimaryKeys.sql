-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'statistics';

ALTER TABLE log_statistic ADD CONSTRAINT log_statistic_pkey PRIMARY KEY (name, category, timestamp);
ALTER TABLE statistic ADD CONSTRAINT statistic_pkey PRIMARY KEY (id);
ALTER TABLE statistic_event ADD CONSTRAINT statistic_event_pkey PRIMARY KEY (date);
