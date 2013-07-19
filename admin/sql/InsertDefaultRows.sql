\set ON_ERROR_STOP 1

BEGIN;

INSERT INTO artist_name (id, name) VALUES
    (1, 'Various Artists'),
    (2, 'Deleted Artist');

INSERT INTO artist (name, sort_name, gid) VALUES
    (1, 1, '89ad4ac3-39f7-470e-963a-56509c546377'),
    (2, 2, 'c06aa285-520e-40c0-b776-83d2c9e8a6d1');

INSERT INTO label_name (id, name) VALUES
    (1, 'Deleted Label');

INSERT INTO label (name, sort_name, gid) VALUES
    (1, 1, 'f43e252d-9ebf-4e8e-bba8-36d080756cc1');

INSERT INTO editor (id, name, password, ha1) VALUES (1, 'Anonymous', '', '');
INSERT INTO editor (id, name, password, ha1) VALUES (2, 'FreeDB', '', '');
INSERT INTO editor (id, name, password, ha1) VALUES (4, 'ModBot', '', '');

INSERT INTO clientversion (id, version) VALUES (1, 'unknown');

INSERT INTO replication_control VALUES (
    1,   -- fixed primary key
    1,   -- schema #1
    NULL,-- until we pull in a particular dump, we don't know what replication sequence we're at
    NULL
);

COMMIT;

-- vi: set ts=4 sw=4 et :
