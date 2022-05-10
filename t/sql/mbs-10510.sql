-- Automatically generated, do not edit.
-- release 546d165a-3fa9-423b-acb8-0fd6342a44f1 45c1c4d2-ee85-4872-8af4-acd1ae9c3c31

SET client_min_messages TO 'warning';

-- Temporarily drop triggers.
DROP TRIGGER deny_deprecated ON link;

INSERT INTO musicbrainz.area (id, gid, name, type, edits_pending, last_updated, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, ended, comment) VALUES
	(269, 'af59135f-38b5-4ea4-b4e2-dd28c5f0bad7', 'Washington, D.C.', 2, 0, '2013-08-17 16:31:00.306126+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(7952, '759f9567-9107-40ef-a825-e57824a62e70', 'St. Louis', 3, 0, '2013-05-29 08:22:56.510164+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', '');
INSERT INTO musicbrainz.iso_3166_2 (area, code) VALUES
	(269, 'US-DC');
INSERT INTO musicbrainz.artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, type, area, gender, comment, edits_pending, last_updated, ended, begin_area, end_area) VALUES
	(288820, '6b82c839-ea15-4d3b-96f1-d1be924e9cb7', 'Hamilton Leithauser', 'Leithauser, Hamilton', NULL, NULL, NULL, NULL, NULL, NULL, 1, 222, 1, '', 0, '2015-07-15 23:29:08.652546+00', '0', 269, NULL),
	(804408, '185527bf-c293-4c24-8213-ed98fb8976be', 'Angel Olsen', 'Olsen, Angel', 1987, 1, 22, NULL, NULL, NULL, 1, 222, 2, '', 0, '2016-09-04 19:37:51.849992+00', '0', 7952, NULL);
INSERT INTO musicbrainz.artist_ipi (artist, ipi, edits_pending, created) VALUES
	(804408, '00686537595', 0, '2014-11-05 03:00:13.359654+00');
INSERT INTO musicbrainz.artist_isni (artist, isni, edits_pending, created) VALUES
	(288820, '0000000406679798', 0, '2015-07-15 23:29:08.652546+00');
INSERT INTO musicbrainz.artist_credit (id, name, artist_count, ref_count, created, edits_pending, gid) VALUES
	(2088588, 'Hamilton Leithauser featuring Angel Olsen', 2, 4, '2017-10-13 17:53:24.63341+00', 0, '8b6c7da9-1264-335d-80e5-769f7be59c0f'),
	(2091168, 'Hamilton Leithauser & Angel Olsen', 2, 4, '2017-10-17 22:10:19.31387+00', 0, '5467a9c8-e453-394e-be12-6aa8a764dfe7');
INSERT INTO musicbrainz.artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
	(2088588, 0, 288820, 'Hamilton Leithauser', ' featuring '),
	(2088588, 1, 804408, 'Angel Olsen', ''),
	(2091168, 0, 288820, 'Hamilton Leithauser', ' & '),
	(2091168, 1, 804408, 'Angel Olsen', '');
INSERT INTO musicbrainz.release_group (id, gid, name, artist_credit, type, comment, edits_pending, last_updated) VALUES
	(1869896, '0e633641-0910-4084-bbb5-6b3aaabf1e9d', 'Heartstruck (Wild Hunger)', 2088588, 2, '', 0, '2017-10-29 13:09:45.96357+00'),
	(1871823, 'f919772e-425e-4060-b654-e0526c2baf7b', 'Heartstruck (Wild Hunger)', 2091168, 2, '', 0, '2017-10-29 13:09:45.96357+00');
INSERT INTO musicbrainz.release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode, comment, edits_pending, quality, last_updated) VALUES
	(2047097, '45c1c4d2-ee85-4872-8af4-acd1ae9c3c31', 'Heartstruck (Wild Hunger)', 2088588, 1869896, 1, NULL, NULL, NULL, NULL, '', 0, -1, '2017-10-29 13:10:45.95418+00'),
	(2049596, '546d165a-3fa9-423b-acb8-0fd6342a44f1', 'Heartstruck (Wild Hunger)', 2091168, 1871823, 1, 7, 120, 28, NULL, '', 0, -1, '2017-10-29 13:10:45.95418+00');
INSERT INTO musicbrainz.release_unknown_country (release, date_year, date_month, date_day) VALUES
	(2047097, 2017, NULL, NULL);
INSERT INTO musicbrainz.release_country (release, country, date_year, date_month, date_day) VALUES
	(2049596, 222, 2017, 10, 12);
INSERT INTO musicbrainz.label (id, gid, name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, label_code, type, area, comment, edits_pending, last_updated, ended) VALUES
	(19791, '58c69b6f-5c5b-4341-8be6-a43c3e69b408', 'Glassnote', 2007, NULL, NULL, NULL, NULL, NULL, NULL, 9, 222, 'logo is a capital G with an eighth note; imprint of Glassnote Entertainment Group LLC', 0, '2016-04-26 07:13:14.300186+00', '0');
INSERT INTO musicbrainz.release_label (id, release, label, catalog_number, last_updated) VALUES
	(1571316, 2049596, 19791, NULL, '2017-10-17 22:10:24.561209+00');
INSERT INTO musicbrainz.medium (id, release, position, format, name, edits_pending, last_updated, track_count) VALUES
	(2198755, 2047097, 1, 12, '', 0, '2017-10-13 17:53:30.633711+00', 1),
	(2201664, 2049596, 1, 12, '', 0, '2017-10-17 22:10:26.919104+00', 1);
INSERT INTO musicbrainz.medium_index (medium, toc) VALUES
	(2198755, '(210000, 0, 0, 0, 0, 0)'),
	(2201664, '(210651, 0, 0, 0, 0, 0)');
INSERT INTO musicbrainz.recording (id, gid, name, artist_credit, length, comment, edits_pending, last_updated, video) VALUES
	(21622705, 'fab8ace7-2f64-4990-889b-581b309298ab', 'Heartstruck (Wild Hunger)', 2088588, 210000, '', 0, '2017-10-13 17:53:30.633711+00', '0'),
	(21643730, '13de1d98-e302-4922-9f25-4dbd776c5ebf', 'Heartstruck (Wild Hunger)', 2091168, 210651, '', 0, '2017-10-17 22:10:26.919104+00', '0');
INSERT INTO musicbrainz.track (id, gid, recording, medium, position, number, name, artist_credit, length, edits_pending, last_updated, is_data_track) VALUES
	(23961922, 'ba2dafe8-1f21-4d0c-a034-3a9257fa575f', 21622705, 2198755, 1, '1', 'Heartstruck (Wild Hunger)', 2088588, 210000, 0, '2017-10-13 17:53:30.633711+00', '0'),
	(23990533, '9dc36e26-06cd-4a32-b158-34aeedb16b53', 21643730, 2201664, 1, '1', 'Heartstruck (Wild Hunger)', 2091168, 210651, 0, '2017-10-17 22:10:26.919104+00', '0');

-- Restore triggers.
CREATE TRIGGER deny_deprecated BEFORE UPDATE OR INSERT ON link FOR EACH ROW EXECUTE PROCEDURE deny_deprecated_links();
