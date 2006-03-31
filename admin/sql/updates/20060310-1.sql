-- Abstract: create and populate the puid* tables

\set ON_ERROR_STOP 1

BEGIN;

-- Create the PUID tables
CREATE TABLE puid
(
    id                  SERIAL,
    puid                CHAR(36) NOT NULL,
    lookupcount         INTEGER NOT NULL DEFAULT 0, -- updated via trigger
    version             INTEGER NOT NULL -- references clientversion
);  

CREATE TABLE puid_stat
(
    id                  SERIAL,
    puid_id             INTEGER NOT NULL, -- references puid
    month_id            INTEGER NOT NULL,
    lookupcount         INTEGER NOT NULL DEFAULT 0
);  
    
CREATE TABLE puidjoin   
(   
    id                  SERIAL, 
    puid                INTEGER NOT NULL, -- references puid
    track               INTEGER NOT NULL, -- references track
    usecount            INTEGER DEFAULT 0 -- updated via trigger
);
    
CREATE TABLE puidjoin_stat
(
    id                  SERIAL,
    puidjoin_id         INTEGER NOT NULL, -- references puidjoin
    month_id            INTEGER NOT NULL,
    usecount            INTEGER NOT NULL DEFAULT 0
);  

-- alter the album meta table to include the puids column
-- Not done here, since regenerating albummeta completely recreates the table
-- alter table albummeta add column puids INTEGER DEFAULT 0;

-- next up, import the data
\COPY puid FROM '/tmp/puid.dat'
\COPY puidjoin FROM '/tmp/puidjoin.dat'

-- then create indexes and FKs
ALTER TABLE puid ADD CONSTRAINT puid_pkey PRIMARY KEY (id);
ALTER TABLE puid_stat ADD CONSTRAINT puid_stat_pkey PRIMARY KEY (id);
ALTER TABLE puidjoin ADD CONSTRAINT puidjoin_pkey PRIMARY KEY (id);
ALTER TABLE puidjoin_stat ADD CONSTRAINT puidjoin_stat_pkey PRIMARY KEY (id);

CREATE UNIQUE INDEX puid_puidindex ON puid (puid);
CREATE UNIQUE INDEX puid_stat_puid_idindex ON puid_stat (puid_id, month_id);
CREATE INDEX puidjoin_trackindex ON puidjoin (track);
CREATE UNIQUE INDEX puidjoin_puidtrack ON puidjoin (puid, track);
CREATE UNIQUE INDEX puidjoin_stat_puidjoin_idindex ON puidjoin_stat (puidjoin_id, month_id);

ALTER TABLE puid
    ADD CONSTRAINT puid_fk_clientversion
    FOREIGN KEY (version)
    REFERENCES clientversion(id);
ALTER TABLE puidjoin
    ADD CONSTRAINT puidjoin_fk_track
    FOREIGN KEY (track)
    REFERENCES track(id);
ALTER TABLE puidjoin
    ADD CONSTRAINT puidjoin_fk_puid
    FOREIGN KEY (puid)
    REFERENCES puid(id);
ALTER TABLE puidjoin_stat
    ADD CONSTRAINT puidjoin_stat_fk_puidjoin
    FOREIGN KEY (puidjoin_id)
    REFERENCES puidjoin(id)
    ON DELETE CASCADE;
ALTER TABLE puid_stat
    ADD CONSTRAINT puid_stat_fk_puid
    FOREIGN KEY (puid_id)
    REFERENCES puid(id)
    ON DELETE CASCADE;

COMMIT;

VACUUM ANALYZE puid;
VACUUM ANALYZE puidjoin;

-- vi: set ts=4 sw=4 et :
