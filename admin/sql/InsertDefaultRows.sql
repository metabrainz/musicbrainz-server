\set ON_ERROR_STOP 1

BEGIN;

INSERT INTO artist (name, sort_name, gid) VALUES
    ('Various Artists', 'Various Artists', '89ad4ac3-39f7-470e-963a-56509c546377'),
    ('Deleted Artist', 'Deleted Artist', 'c06aa285-520e-40c0-b776-83d2c9e8a6d1');

INSERT INTO label (name, gid) VALUES
    ('Deleted Label', 'f43e252d-9ebf-4e8e-bba8-36d080756cc1');

INSERT INTO editor (id, name, password, ha1) VALUES (1, 'Anonymous', '', '');
INSERT INTO editor (id, name, password, ha1) VALUES (2, 'FreeDB', '', '');
INSERT INTO editor (id, name, password, ha1) VALUES (4, 'ModBot', '', '');

INSERT INTO replication_control VALUES (
    1,   -- fixed primary key
    1,   -- schema #1
    NULL,-- until we pull in a particular dump, we don't know what replication sequence we're at
    NULL
);

INSERT INTO release_group_primary_type VALUES (1, 'Album', null, 1, null, 'f529b476-6e62-324f-b0aa-1f3e33d313fc');
INSERT INTO release_group_primary_type VALUES (2, 'Single', null, 2, null, 'd6038452-8ee0-3f68-affc-2de9a1ede0b9');

INSERT INTO release_status VALUES (1, 'Official', null, 1, null, '4e304316-386d-3409-af2e-78857eec5cfe');

INSERT INTO series_type_allowed_entity_type (entity_type) VALUES
    ('event'),
    ('recording'),
    ('release'),
    ('release_group'),
    ('work');

COMMIT;

-- vi: set ts=4 sw=4 et :
