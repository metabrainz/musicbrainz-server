BEGIN;
SET client_min_messages TO 'WARNING';

INSERT INTO gender VALUES (1, 'Male', NULL, 1, NULL);
INSERT INTO gender VALUES (2, 'Female', NULL, 2, NULL);
INSERT INTO gender VALUES (3, 'Other', NULL, 3, NULL);

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

INSERT INTO series_ordering_type VALUES (1, 'Automatic', NULL, 0, 'Sorts the items in the series automatically by their number attributes, using a natural sort order.');
INSERT INTO series_ordering_type VALUES (2, 'Manual', NULL, 1, 'Allows for manually setting the position of each item in the series.');

INSERT INTO series_type VALUES (1, 'Release group', 'release_group', NULL, 0, 'A series of release groups.');
INSERT INTO series_type VALUES (2, 'Release', 'release', NULL, 1, 'A series of releases.');
INSERT INTO series_type VALUES (3, 'Recording', 'recording', NULL, 2, 'A series of recordings.');
INSERT INTO series_type VALUES (4, 'Work', 'work', NULL, 3, 'A series of works.');
INSERT INTO series_type VALUES (5, 'Catalogue', 'work', 4, 0, 'A series of works which form a catalogue of classical compositions.');
INSERT INTO series_type VALUES (6, 'Event', 'event', NULL, 5, 'A series of events.');
INSERT INTO series_type VALUES (7, 'Tour', 'event', 6, 0, 'A series of related concerts by an artist in different locations.');
INSERT INTO series_type VALUES (8, 'Festival', 'event', 6, 1, 'A recurring festival, usually happening annually in the same location.');
INSERT INTO series_type VALUES (9, 'Run', 'event', 6, 2, 'A series of performances of the same show at the same venue.');

COMMIT;
