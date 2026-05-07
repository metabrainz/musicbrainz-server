\set ON_ERROR_STOP 1

BEGIN;

DROP MATERIALIZED VIEW IF EXISTS dbmirror2.column_info CASCADE;
DROP TABLE IF EXISTS dbmirror2.pending_keys CASCADE;
DROP TABLE IF EXISTS dbmirror2.pending_ts CASCADE;
DROP TABLE IF EXISTS dbmirror2.pending_data CASCADE;
DROP EVENT TRIGGER IF EXISTS refresh_column_info;
DROP FUNCTION IF EXISTS dbmirror2.refresh_column_info();

CREATE OR REPLACE FUNCTION dbmirror2.recordchange()
RETURNS trigger AS $$
DECLARE
    -- prefixed with an underscore to disambiguate it from the column names
    -- pending_data.tablename and pending_keys.tablename
    _tablename  TEXT;
    keys        TEXT[];
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

    INSERT INTO dbmirror2.pending_ts (xid, ts)
    VALUES (txid_current(), transaction_timestamp())
    ON CONFLICT DO NOTHING;

    IF TG_OP != 'INSERT' THEN
        xoldctid := OLD.ctid;
    END IF;

    IF TG_OP != 'DELETE' THEN
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
        row_to_json(OLD),
        row_to_json(NEW),
        xoldctid,
        pg_trigger_depth()
    );

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE dbmirror2.pending_keys (
    tablename   TEXT,
    keys        TEXT[] NOT NULL
);

ALTER TABLE dbmirror2.pending_keys
    ADD CONSTRAINT pending_keys_pkey
    PRIMARY KEY (tablename);

CREATE TABLE dbmirror2.pending_ts (
    xid BIGINT,
    ts TIMESTAMP WITH TIME ZONE NOT NULL
);

ALTER TABLE dbmirror2.pending_ts
    ADD CONSTRAINT pending_ts_pkey
    PRIMARY KEY (xid);

CREATE TABLE dbmirror2.pending_data (
    seqid       BIGSERIAL,
    tablename   TEXT NOT NULL CONSTRAINT tablename_exists CHECK (to_regclass(tablename) IS NOT NULL),
    op          "char" NOT NULL CONSTRAINT op_in_diu CHECK (op IN ('d', 'i', 'u')),
    xid         BIGINT NOT NULL,
    olddata     JSON CONSTRAINT olddata_is_null_for_inserts CHECK ((olddata IS NULL) = (op = 'i')),
    newdata     JSON CONSTRAINT newdata_is_null_for_deletes CHECK ((newdata IS NULL) = (op = 'd')),
    oldctid     TID,
    trgdepth    INTEGER
);

ALTER TABLE dbmirror2.pending_data
    ADD CONSTRAINT pending_data_pkey
    PRIMARY KEY (seqid);

CREATE INDEX pending_data_idx_xid_seqid
    ON dbmirror2.pending_data (xid, seqid);

CREATE INDEX pending_data_idx_oldctid_xid
    ON dbmirror2.pending_data (oldctid, xid);

COMMIT;
