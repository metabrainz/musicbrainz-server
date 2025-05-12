\set ON_ERROR_STOP 1

BEGIN;

DO $$
DECLARE
    r record;
BEGIN
    FOR r IN (
        SELECT *
        FROM information_schema.triggers
        WHERE action_statement LIKE '%b_upd_last_updated_table%'
    ) LOOP
        EXECUTE 'ALTER TABLE ' ||
            quote_ident(r.event_object_schema) || '.' ||
            quote_ident(r.event_object_table) ||
            ' ENABLE TRIGGER ' ||
            quote_ident(r.trigger_name);
    END LOOP;
END $$;

COMMIT;
