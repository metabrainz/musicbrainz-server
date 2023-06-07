-- Automatically generated, do not edit.
-- release 26c37f78-4931-4c2d-bb7a-4003807ec7c4

SET client_min_messages TO 'warning';

INSERT INTO musicbrainz.artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, type, area, gender, comment, edits_pending, last_updated, ended, begin_area, end_area) VALUES
	(2042159, '8a9d0b90-951e-4ab8-b2dc-9d3618af3d28', 'Mori Calliope', 'Mori, Calliope', 2020, 9, 12, NULL, NULL, NULL, 4, NULL, 2, 'virtual YouTuber, hololive EN', 0, '2022-12-23 05:00:18.326884+00', '0', NULL, NULL);
INSERT INTO musicbrainz.artist_credit (id, name, artist_count, ref_count, created, edits_pending, gid) VALUES
	(2916231, 'Mori Calliope', 1, 237, '2021-02-01 15:03:55.706555+00', 0, 'c33da1db-09eb-3644-8f57-467648359a0e');
INSERT INTO musicbrainz.artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
	(2916231, 0, 2042159, 'Mori Calliope', '');
INSERT INTO musicbrainz.release_group (id, gid, name, artist_credit, type, comment, edits_pending, last_updated) VALUES
	(3262118, 'da38d028-7474-4039-9f79-f31619b8c2df', '【MV】可愛くてごめん // Sorry I''m So Cute!', 2916231, 2, '', 0, '2023-03-28 02:56:21.230707+00');
INSERT INTO musicbrainz.release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode, comment, edits_pending, quality, last_updated) VALUES
	(3821712, '26c37f78-4931-4c2d-bb7a-4003807ec7c4', '【MV】可愛くてごめん // Sorry I''m So Cute!', 2916231, 3262118, 1, 7, 120, 28, '', '', 1, -1, '2023-03-28 02:57:49.63927+00');
INSERT INTO musicbrainz.medium (id, release, position, format, name, edits_pending, last_updated, track_count) VALUES
	(4162932, 3821712, 1, 12, '', 0, '2023-03-28 02:56:28.474663+00', 0);
INSERT INTO musicbrainz.recording (id, gid, name, artist_credit, length, comment, edits_pending, last_updated, video) VALUES
	(34603043, 'e9f29649-9c3c-4c88-8a66-53383cf7e614', '可愛くてごめん // Sorry I''m So Cute!', 2916231, 220000, '', 0, '2023-03-28 13:20:18.287861+00', '1');
INSERT INTO musicbrainz.url (id, gid, url, edits_pending, last_updated) VALUES
	(10786893, 'fb8ff3b2-35b2-489a-ac20-6ff728b1828a', 'https://www.youtube.com/watch?v=92tvv7PgKeI', 0, '2023-03-28 02:56:35.353783+00');
INSERT INTO musicbrainz.link (id, link_type, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, attribute_count, created, ended) VALUES
	(30361, 268, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2011-10-13 21:23:57.982253+00', '0');
INSERT INTO musicbrainz.link_attribute (link, attribute_type, created) VALUES
	(30361, 582, '2011-10-13 21:23:57.982253+00');
INSERT INTO musicbrainz.l_recording_url (id, link, entity0, entity1, edits_pending, last_updated, link_order, entity0_credit, entity1_credit) VALUES
	(228072, 30361, 34603043, 10786893, 0, '2023-03-28 02:57:53.944171+00', 0, '', '');
INSERT INTO musicbrainz.track (id, gid, recording, medium, position, number, name, artist_credit, length, edits_pending, last_updated, is_data_track) VALUES
	(41912126, '2647d373-6e73-4c20-9352-ad30e4536187', 34603043, 4162932, 1, '1', '可愛くてごめん // Sorry I''m So Cute!', 2916231, 220000, 0, '2023-03-28 02:56:28.474663+00', '0');
