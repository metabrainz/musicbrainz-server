SET search_path = 'musicbrainz', 'public';

BEGIN;

SELECT no_plan();

SET CONSTRAINTS ALL IMMEDIATE;

INSERT INTO artist (id, gid, name, sort_name)
     VALUES (1, 'c63ecb0c-89af-4c26-928b-807402b1d701', 'Artist', 'Artist');

INSERT INTO artist_credit (id, artist_count, name, gid)
     VALUES (1, 1, 'Artist', '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

INSERT INTO label (id, gid, name)
     VALUES (1, '79cde6f7-80b1-45bf-9512-568bad5a54d6', 'Label 1'),
            (2, '6774c419-f181-4964-ac32-e97f82929390', 'Label 2');

INSERT INTO release_group (id, gid, name, artist_credit)
     VALUES (1, '28cb82a8-ccd2-4168-8c39-c08594fee1d9', 'Release Group', 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
     VALUES (1, '28cb82a8-ccd2-4168-8c39-c08594fee1d9', 'Release', 1, 1);

INSERT INTO release_label (id, release, label, catalog_number)
     VALUES (1, 1, 1, NULL),
            (2, 1, 2, 'ABC'),
            (3, 1, NULL, 'ABC');

SELECT throws_like(
  'INSERT INTO release_label (id, release, label, catalog_number)
        VALUES (4, 1, 1, NULL);',
  'duplicate key value violates unique constraint "release_label_uniq"'
);

SELECT throws_like(
  'INSERT INTO release_label (id, release, label, catalog_number)
        VALUES (4, 1, 2, ''ABC'');',
  'duplicate key value violates unique constraint "release_label_uniq"'
);

SELECT throws_like(
  'INSERT INTO release_label (id, release, label, catalog_number)
        VALUES (4, 1, NULL, ''ABC'');',
  'duplicate key value violates unique constraint "release_label_uniq"'
);

SELECT finish();

ROLLBACK;
