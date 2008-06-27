\set ON_ERROR_STOP 1

BEGIN;

-- Add timestamps to entities
alter table artist add column lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW();
alter table album  add column lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW();
alter table label  add column lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW();
alter table track  add column lastupdate          TIMESTAMP WITH TIME ZONE DEFAULT NOW();

COMMIT;
