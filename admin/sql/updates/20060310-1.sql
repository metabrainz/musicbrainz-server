-- Abstract: add the wiki_transclusion table

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
alter table albummeta add column puids INTEGER DEFAULT 0;

-- next up, import the data, then create indexes and FKs

COMMIT;

-- vi: set ts=4 sw=4 et :
