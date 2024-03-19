-- Generated by CompileSchemaScripts.pl from:
-- 20231005-edit-data-idx-link-type.sql
-- 20240319-mbs-13514.sql
\set ON_ERROR_STOP 1
BEGIN;
SET search_path = musicbrainz, public;
SET LOCAL statement_timeout = 0;
--------------------------------------------------------------------------------
SELECT '20231005-edit-data-idx-link-type.sql';


DROP INDEX CONCURRENTLY IF EXISTS edit_data_idx_link_type;

CREATE INDEX CONCURRENTLY edit_data_idx_link_type ON edit_data USING GIN (
    array_remove(ARRAY[
                     (data#>>'{link_type,id}')::int,
                     (data#>>'{link,link_type,id}')::int,
                     (data#>>'{old,link_type,id}')::int,
                     (data#>>'{new,link_type,id}')::int,
                     (data#>>'{relationship,link,type,id}')::int
                 ], NULL)
);

--------------------------------------------------------------------------------
SELECT '20240319-mbs-13514.sql';


ALTER TABLE label DROP CONSTRAINT IF EXISTS label_label_code_check;

ALTER TABLE label DROP CONSTRAINT IF EXISTS label_code_length;

ALTER TABLE label ADD CONSTRAINT label_code_length CHECK (label_code > 0 AND label_code < 1000000);

COMMIT;
