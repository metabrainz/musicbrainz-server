BEGIN;
SET client_min_messages TO 'WARNING';

INSERT INTO release_group_primary_type VALUES (1, 'Album', NULL, 1, NULL);
INSERT INTO release_group_primary_type VALUES (2, 'Single', NULL, 2, NULL);
INSERT INTO release_group_primary_type VALUES (3, 'EP', NULL, 3, NULL);
INSERT INTO release_group_primary_type VALUES (12, 'Broadcast', NULL, 4, NULL);
INSERT INTO release_group_primary_type VALUES (11, 'Other', NULL, 99, NULL);

INSERT INTO release_group_secondary_type VALUES (1, 'Compilation', NULL, 0, NULL);
INSERT INTO release_group_secondary_type VALUES (2, 'Soundtrack', NULL, 0, NULL);
INSERT INTO release_group_secondary_type VALUES (3, 'Spokenword', NULL, 0, NULL);
INSERT INTO release_group_secondary_type VALUES (4, 'Interview', NULL, 0, NULL);
INSERT INTO release_group_secondary_type VALUES (5, 'Audiobook', NULL, 0, NULL);
INSERT INTO release_group_secondary_type VALUES (6, 'Live', NULL, 0, NULL);
INSERT INTO release_group_secondary_type VALUES (7, 'Remix', NULL, 0, NULL);
INSERT INTO release_group_secondary_type VALUES (8, 'DJ-mix', NULL, 0, NULL);
INSERT INTO release_group_secondary_type VALUES (9, 'Mixtape/Street', NULL, 0, NULL);
INSERT INTO release_group_secondary_type VALUES (10, 'Demo', NULL, 0, NULL);

INSERT INTO release_status VALUES (1, 'Official', NULL, 1, NULL);
INSERT INTO release_status VALUES (2, 'Promotion', NULL, 2, NULL);
INSERT INTO release_status VALUES (3, 'Bootleg', NULL, 3, NULL);
INSERT INTO release_status VALUES (4, 'Pseudo-Release', NULL, 4, NULL);

COMMIT;
