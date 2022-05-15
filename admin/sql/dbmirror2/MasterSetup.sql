-- Copyright (C) 2021 MetaBrainz Foundation
-- Licensed under the GPL version 2, or (at your option) any later version:
-- http://www.gnu.org/licenses/gpl-2.0.txt

BEGIN;

-- The column_info view allows us to determine whether a column in a given
-- table is part of its primary key, and gives us its position too.
--
-- This view must be refreshed after every schema change; an event trigger
-- in MasterEventTriggerSetup.sql can handle this automatically.
CREATE MATERIALIZED VIEW dbmirror2.column_info (
    table_schema,
    table_name,
    column_name,
    position,
    is_primary
) AS
    SELECT
        c.table_schema,
        c.table_name,
        c.column_name,
        c.ordinal_position,
        coalesce((
            SELECT TRUE
            FROM information_schema.key_column_usage kcu
            NATURAL JOIN information_schema.table_constraints tc
            WHERE kcu.table_schema = c.table_schema
            AND kcu.table_name = c.table_name
            AND kcu.column_name = c.column_name
            AND tc.constraint_type = 'PRIMARY KEY'
        ), FALSE) AS is_primary
    FROM information_schema.columns c
    NATURAL JOIN information_schema.tables t
    WHERE t.table_type = 'BASE TABLE'
    AND t.table_schema NOT IN ('dbmirror2', 'information_schema', 'pg_catalog')
WITH DATA;

CREATE INDEX column_info_idx
    ON dbmirror2.column_info (table_schema, table_name, is_primary);

CREATE FUNCTION dbmirror2.recordchange()
RETURNS trigger AS $$
DECLARE
    -- prefixed with an underscore to disambiguate it from the column names
    -- pending_data.tablename and pending_keys.tablename
    _tablename  TEXT;
    keys        TEXT[];
    jsonquery   TEXT;
    olddata     JSON;
    newdata     JSON;
    -- prefixed with 'x' to avoid conflict with column name in queries
    xoldctid    TID;
    nextseqid   BIGINT;
    -- out-of-order seqid
    oooseqid    BIGINT;
    oootrgdepth INTEGER;
    pdcursor    NO SCROLL CURSOR (oooseqid INTEGER) FOR
                    SELECT seqid
                    FROM dbmirror2.pending_data
                    WHERE xid = txid_current()
                    AND seqid >= oooseqid
                    ORDER BY seqid DESC
                    FOR UPDATE;
BEGIN
    _tablename := (
        quote_ident(TG_TABLE_SCHEMA) || '.' || quote_ident(TG_TABLE_NAME)
    );

    nextseqid := nextval(
        pg_get_serial_sequence('dbmirror2.pending_data', 'seqid')
    );

    INSERT INTO dbmirror2.pending_keys (tablename, keys)
    VALUES (
        _tablename,
        (
            SELECT array_agg(column_name)
            FROM dbmirror2.column_info
            WHERE table_schema = TG_TABLE_SCHEMA
            AND table_name = TG_TABLE_NAME
            AND is_primary = TRUE
        )
    )
    ON CONFLICT DO NOTHING;

    INSERT INTO dbmirror2.pending_ts (xid, ts)
    VALUES (txid_current(), transaction_timestamp())
    ON CONFLICT DO NOTHING;

    jsonquery := (
        SELECT format(
            'SELECT json_build_object(%1$s)',
            array_to_string(
                array_agg(
                    format('%1$L, ($1).%1$I', column_name) ORDER BY position
                ),
                ', '
            )
        )
        FROM dbmirror2.column_info
        WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME
    );

    IF TG_OP != 'INSERT' THEN
        EXECUTE jsonquery INTO olddata USING OLD;

        xoldctid := OLD.ctid;
    END IF;

    IF TG_OP != 'DELETE' THEN
        EXECUTE jsonquery INTO newdata USING NEW;

        -- Detect out-of-order operations caused by cascading triggers.
        --
        -- When row-level AFTER triggers are cascaded, the innermost trigger
        -- runs first. This means we may potentially see an UPDATE or DELETE
        -- of a row version that hasn't been added yet.
        --
        -- We detect this by storing OLD.ctid for every operation. (The ctid
        -- is a tuple describing the physical location of the row version. We
        -- only need this to be stable for the lifetime of the current
        -- transaction.) We then check if there's a previous operation whose
        -- OLD ctid equals our NEW ctid; these are then known to be out-of-
        -- order. This previous operation's seqid is assigned to `oooseqid`
        -- ("out-of-order seqid").
        --
        -- The order is fixed by shifting the sequence IDs from the current
        -- transaction until they're corrected. The current-last operation
        -- assumes `nextseqid`, the second-to-last assumes the seqid of the
        -- last, and so on until `oooseqid` is unused. We then insert our new
        -- operation with `oooseqid`.
        --
        -- Since we're never modifying `pending_data` rows inserted by other
        -- transactions, this shifting should be safe.
        SELECT seqid, trgdepth INTO oooseqid, oootrgdepth
        FROM dbmirror2.pending_data
        WHERE xid = txid_current()
        AND tablename = _tablename
        AND oldctid = NEW.ctid;

        IF FOUND THEN
            IF oootrgdepth IS NOT NULL AND oootrgdepth <= pg_trigger_depth() THEN
                -- This should never happen! Cascading triggers are the only
                -- known way for operations to arrive out of order. This
                -- warning must be investigated if it's ever logged.
                RAISE WARNING 'oootrgdepth (%) <= pg_trigger_depth() (%) (% ON %, OLD: %, NEW: %)',
                    oootrgdepth, pg_trigger_depth(), TG_OP, _tablename, OLD, NEW;
            END IF;

            FOR pdrecord IN pdcursor (oooseqid := oooseqid) LOOP
                UPDATE dbmirror2.pending_data
                SET seqid = nextseqid
                WHERE CURRENT OF pdcursor;

                nextseqid := pdrecord.seqid;
            END LOOP;

            ASSERT (nextseqid = oooseqid);
        END IF;
    END IF;

    INSERT INTO dbmirror2.pending_data
        (seqid, tablename, op, xid, olddata, newdata, oldctid, trgdepth)
    VALUES (
        nextseqid,
        _tablename,
        lower(left(TG_OP, 1)),
        txid_current(),
        olddata,
        newdata,
        xoldctid,
        pg_trigger_depth()
    );

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

COMMIT;
