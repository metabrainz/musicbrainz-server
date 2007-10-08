\set ON_ERROR_STOP 1

BEGIN;

insert into Artist (Name, SortName, GID, ModPending, Page) 
      values ('Various Artists', 'Various Artists', 
              '89ad4ac3-39f7-470e-963a-56509c546377', 0, 0); 

insert into Artist (Name, SortName, GID, ModPending, Page) 
      values ('Deleted Artist', 'Deleted Artist', 
              'c06aa285-520e-40c0-b776-83d2c9e8a6d1', 0, 0); 

insert into Label (Name, SortName, GID, ModPending, Page) 
      values ('Deleted Label', 'Deleted Label', 'f43e252d-9ebf-4e8e-bba8-36d080756cc1', 0, 0); 

INSERT INTO moderator (id, name, password) VALUES (1, 'Anonymous', '');
INSERT INTO moderator (id, name, password) VALUES (2, 'FreeDB', '');
INSERT INTO moderator (id, name, password) VALUES (4, 'ModBot', '');

INSERT INTO clientversion (id, version) VALUES (1, 'unknown');

INSERT INTO replication_control VALUES (
    1,   -- fixed primary key
    1,   -- schema #1
    NULL,-- until we pull in a particular dump, we don't know what replication sequence we're at
    NULL
);

COMMIT;

-- vi: set ts=4 sw=4 et :
