BEGIN;

CREATE SCHEMA dbmirror2;

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
