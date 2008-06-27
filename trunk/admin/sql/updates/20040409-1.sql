-- Abstract: Add the replication_control table, add initial data
-- Abstract: Also ensure all tables have a primary key (for replication)

\set ON_ERROR_STOP 1

BEGIN;

-- This table needs a primary key, just so the replication system can deal
-- with it.  But there should only ever be one row in this table, and the
-- primary key should never change.

CREATE TABLE replication_control
(
    id                              SERIAL,
    current_schema_sequence         INTEGER NOT NULL,
    current_replication_sequence    INTEGER,
    last_replication_date           TIMESTAMP WITH TIME ZONE
);

INSERT INTO replication_control VALUES (
    1,   -- fixed primary key
    1,   -- after this DB upgrade, we're at schema #1
    NULL,-- until we pull in a particular dump, we don't know what replication sequence we're at
    NULL
);

ALTER TABLE replication_control ADD CONSTRAINT replication_control_pkey PRIMARY KEY (id);

DROP INDEX albumwords_albumwordindex;
DROP INDEX artistwords_artistwordindex;
DROP INDEX historicalstat_namedate;
DROP INDEX trackwords_trackwordindex;

ALTER TABLE albumwords ADD CONSTRAINT albumwords_pkey PRIMARY KEY (wordid, albumid);
ALTER TABLE artistwords ADD CONSTRAINT artistwords_pkey PRIMARY KEY (wordid, artistid);
ALTER TABLE historicalstat ADD CONSTRAINT historicalstat_pkey PRIMARY KEY (name, snapshotdate);
ALTER TABLE trackwords ADD CONSTRAINT trackwords_pkey PRIMARY KEY (wordid, trackid);

COMMIT;

-- vi: set ts=4 sw=4 et :
