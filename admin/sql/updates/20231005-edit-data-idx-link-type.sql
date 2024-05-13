\set ON_ERROR_STOP 1

BEGIN;

DROP INDEX IF EXISTS edit_data_idx_link_type;

CREATE INDEX edit_data_idx_link_type ON edit_data USING GIN (
    array_remove(ARRAY[
                     (data#>>'{link_type,id}')::int,
                     (data#>>'{link,link_type,id}')::int,
                     (data#>>'{old,link_type,id}')::int,
                     (data#>>'{new,link_type,id}')::int,
                     (data#>>'{relationship,link,type,id}')::int
                 ], NULL)
);

COMMIT;
