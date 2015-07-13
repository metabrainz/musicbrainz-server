BEGIN;
SET client_min_messages TO 'WARNING';

INSERT INTO event_type VALUES (1, 'Concert', NULL, 1, 'An individual concert by a single artist or collaboration, often with supporting artists who perform before the main act.');
INSERT INTO event_type VALUES (2, 'Festival', NULL, 2, 'An event where a number of different acts perform across the course of the day. Larger festivals may be spread across multiple days.');
INSERT INTO event_type VALUES (3, 'Launch event', NULL, 3, 'A party, reception or other event held specifically for the launch of a release.');
INSERT INTO event_type VALUES (5, 'Masterclass/Clinic', NULL, 5, 'A masterclass or clinic is an event where an artist meets with a small to medium-sized audience and instructs them individually and/or takes questions intended to improve the audience members'' playing skills.');
INSERT INTO event_type VALUES (4, 'Convention/Expo', NULL, 4, 'A convention, expo or trade fair is an event which is not typically orientated around music performances, but can include them as side activities.');

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
