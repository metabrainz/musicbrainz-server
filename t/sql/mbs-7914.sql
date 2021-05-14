-- Automatically generated, do not edit.
-- release a3ea3821-5955-4cee-b44f-4f7da8a332f7

SET client_min_messages TO 'warning';

INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
	(NULL, NULL, 7, 7, 1860, '', 0, NULL, 18, 5, 1911, '1', 1, '8d610e51-64b4-4654-b8df-064b0fb7a9d9', 10293, '2014-08-13 10:00:45.722409-05', 'Gustav Mahler', 'Mahler, Gustav', 1);
INSERT INTO artist_alias (artist, begin_date_day, begin_date_month, begin_date_year, edits_pending, end_date_day, end_date_month, end_date_year, ended, id, last_updated, locale, name, primary_for_locale, sort_name, type) VALUES
	(10293, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 69060, '2012-05-15 13:57:13.252186-05', NULL, 'グスタフ・マーラー', '0', 'グスタフ・マーラー', NULL);
INSERT INTO artist_credit (artist_count, created, id, name, ref_count, gid) VALUES
	(1, '2011-05-16 11:32:11.963929-05', 10293, 'Gustav Mahler', 12630, '8be3611a-5fd9-3b69-8cfe-34243b02379b');
INSERT INTO artist_credit_name (artist, artist_credit, join_phrase, name, position) VALUES
	(10293, 10293, '', 'Gustav Mahler', 0);
INSERT INTO release_group (artist_credit, comment, edits_pending, gid, id, last_updated, name, type) VALUES
	(10293, '', 0, '9d693063-3b22-4834-bb97-701d37a4ed37', 1481234, '2016-03-10 11:58:56.073617-06', 'Symphony no. 2', NULL);
INSERT INTO release (artist_credit, barcode, comment, edits_pending, gid, id, language, last_updated, name, packaging, quality, release_group, script, status) VALUES
	(10293, NULL, '', 0, 'a3ea3821-5955-4cee-b44f-4f7da8a332f7', 1550385, NULL, '2016-03-10 11:58:59.048362-06', 'Symphony no. 2', NULL, -1, 1481234, NULL, NULL);
INSERT INTO medium (edits_pending, format, id, last_updated, name, position, release, track_count) VALUES
	(0, NULL, 1624904, '2016-03-10 11:59:01.045484-06', '', 1, 1550385, 1);
INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
	(NULL, NULL, NULL, NULL, 1891, '', 0, NULL, NULL, NULL, NULL, '0', NULL, '509c772e-1164-4457-8d09-0553cfa77d64', 9739, '2014-11-30 14:01:29.548519-06', 'Chicago Symphony Orchestra', 'Chicago Symphony Orchestra', 5);
INSERT INTO artist_alias (artist, begin_date_day, begin_date_month, begin_date_year, edits_pending, end_date_day, end_date_month, end_date_year, ended, id, last_updated, locale, name, primary_for_locale, sort_name, type) VALUES
	(9739, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 58023, '2012-05-15 13:57:13.252186-05', NULL, 'CSO', '0', 'CSO', NULL);
INSERT INTO artist_credit (artist_count, created, id, name, ref_count, gid) VALUES
	(1, '2011-05-16 11:32:11.963929-05', 9739, 'Chicago Symphony Orchestra', 59, '15586615-0b5a-304e-be70-afddad1c0b0e');
INSERT INTO artist_credit_name (artist, artist_credit, join_phrase, name, position) VALUES
	(9739, 9739, '', 'Chicago Symphony Orchestra', 0);
INSERT INTO recording (artist_credit, comment, edits_pending, gid, id, last_updated, length, name, video) VALUES
	(9739, '', 0, '36d398e2-85bf-40d5-8686-4f0b78c80ca8', 17296700, '2016-03-10 12:02:23.150916-06', NULL, 'Symphony no. 2 in C minor: I. Allegro maestoso', '0');
INSERT INTO track (artist_credit, edits_pending, gid, id, is_data_track, last_updated, length, medium, name, number, position, recording) VALUES
	(10293, 0, '8ac89142-1318-490a-bed2-5b0c89b251b2', 17990346, '0', '2016-03-10 11:59:37.6962-06', NULL, 1624904, 'Symphony no. 2 in C minor: I. Allegro maestoso', '1', 1, 17296700);
