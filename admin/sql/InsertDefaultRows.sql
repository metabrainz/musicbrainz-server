\set ON_ERROR_STOP 1

BEGIN;

insert into Artist (Name, SortName, GID, ModPending, Page) 
      values ('Various Artists', 'Various Artists', 
              '89ad4ac3-39f7-470e-963a-56509c546377', 0, 0); 

insert into Artist (Name, SortName, GID, ModPending, Page) 
      values ('Deleted Artist', 'Deleted Artist', 
              'c06aa285-520e-40c0-b776-83d2c9e8a6d1', 0, 0); 

-- Three of these four moderators need fixed IDs, so we must set the sequence
-- first to make sure we get the right ones.
SELECT SETVAL('moderator_id_seq', 1);

INSERT INTO moderator (name, password) VALUES ('Anonymous', '');
INSERT INTO moderator (name, password) VALUES ('FreeDB', '');
INSERT INTO moderator (name, password, privs) VALUES ('rob', '', 1);
INSERT INTO moderator (name, password) VALUES ('ModBot', '');

INSERT INTO clientversion (id, version) VALUES (1, 'unknown');

INSERT INTO replication_control VALUES (
    1,   -- fixed primary key
    1,   -- schema #1
    NULL,-- until we pull in a particular dump, we don't know what replication sequence we're at
    NULL
);

COMMIT;
