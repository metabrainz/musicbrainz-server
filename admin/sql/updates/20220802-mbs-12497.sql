\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE unreferenced_row_log (
    table_name          VARCHAR NOT NULL, -- PK
    row_id              INTEGER NOT NULL, -- PK
    inserted            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION dec_ref_count(tbl varchar, row_id integer, val integer) RETURNS void AS $$
DECLARE
    ref_count integer;
BEGIN
    -- decrement ref_count for the old name,
    -- or prepare it for deletion if ref_count would drop to 0
    EXECUTE 'SELECT ref_count FROM ' || tbl || ' WHERE id = ' || row_id || ' FOR UPDATE' INTO ref_count;
    IF ref_count <= val THEN
        EXECUTE 'INSERT INTO unreferenced_row_log (table_name, row_id) VALUES ($1, $2)' USING tbl, row_id;
    END IF;
    EXECUTE 'UPDATE ' || tbl || ' SET ref_count = ref_count - ' || val || ' WHERE id = ' || row_id;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';

CREATE INDEX unreferenced_row_log_idx_inserted ON unreferenced_row_log USING BRIN (inserted);

COMMIT;
