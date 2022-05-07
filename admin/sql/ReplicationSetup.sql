\set ON_ERROR_STOP 1
SET search_path = musicbrainz;

BEGIN;

-- To "install" the pending.so function, execute this as user postgres
-- Normally this is done by InitDb.pl so you don't really have to worry about it.
--CREATE FUNCTION "recordchange" () RETURNS trigger AS
--'$libdir/pending', 'recordchange' LANGUAGE C;

CREATE AGGREGATE array_cat_agg(int2[]) (
      sfunc       = array_cat,
      stype       = int2[],
      initcond    = '{}'
);

CREATE TABLE dbmirror_Pending (
    SeqId serial,
    TableName varchar NOT NULL,
    Op character,
    XID int4 NOT NULL,
    PRIMARY KEY (SeqId)
);

CREATE INDEX dbmirror_Pending_XID_Index ON dbmirror_Pending (XID);

CREATE TABLE dbmirror_PendingData (
    SeqId int4 NOT NULL,
    IsKey bool NOT NULL,
    Data varchar,
    PRIMARY KEY (SeqId, IsKey) ,
    FOREIGN KEY (SeqId) REFERENCES dbmirror_Pending (SeqId) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMIT;

-- vi: set ts=4 sw=4 et :
