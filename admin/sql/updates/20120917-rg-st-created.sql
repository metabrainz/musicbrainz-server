\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE release_group_secondary_type_join
ADD COLUMN created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT '2012-05-15';

ALTER TABLE release_group_secondary_type_join ALTER COLUMN created SET DEFAULT now();

COMMIT;
