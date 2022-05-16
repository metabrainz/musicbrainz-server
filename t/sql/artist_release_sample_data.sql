INSERT INTO musicbrainz.area (id, gid, name, type, edits_pending, last_updated, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, ended, comment) VALUES
	(38, '71bbafaa-e825-3e15-8ca9-017dcad1748b', 'Canada', 1, 0, '2013-05-27 13:15:52.179105+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(103, '390b05d4-11ec-3bce-a343-703a366b34a5', 'Ireland', 1, 0, '2013-05-27 14:05:21.98788+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(222, '489ce91b-6658-3307-9877-795b68554c98', 'United States', 1, 0, '2013-06-15 18:06:39.59323+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(240, '525d4e18-3d00-31b9-a58b-a146a916de8f', '[Worldwide]', NULL, 0, '2013-08-28 11:55:07.839087+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(7703, '1f40c6e1-47ba-4e35-996f-fe6ee5840e62', 'Los Angeles', 3, 0, '2014-12-11 12:34:38.893537+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(8532, '3f504d54-c40c-487d-bc16-c1990eac887f', 'Westmount', 3, 0, '2013-06-01 15:34:06.811401+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(9622, '462e7952-4fa9-43cd-bc24-2c5c9cd5dd47', 'Dublin', 3, 0, '2013-11-26 08:00:52.741074+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(22284, '72df1f13-6d90-44eb-8889-71a615a817e1', 'Newton', 3, 0, '2013-11-13 01:36:12.66035+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', '');
INSERT INTO musicbrainz.country_area (area) VALUES
	(38),
	(222);
INSERT INTO musicbrainz.iso_3166_1 (area, code) VALUES
	(38, 'CA'),
	(222, 'US'),
	(240, 'XW');
INSERT INTO musicbrainz.artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, type, area, gender, comment, edits_pending, last_updated, ended, begin_area, end_area) VALUES
	(1, '89ad4ac3-39f7-470e-963a-56509c546377', 'Various Artists', 'Various Artists', NULL, NULL, NULL, NULL, NULL, NULL, 3, NULL, NULL, 'add compilations to this artist', 0, '2021-04-19 06:00:46.40916+00', '0', NULL, NULL),
	(60, 'c0b2500e-0cef-4130-869d-732b23ed9df5', 'Tori Amos', 'Amos, Tori', 1963, 8, 22, NULL, NULL, NULL, 1, 222, 2, '', 0, '2019-06-13 05:00:18.032217+00', '0', 22284, NULL),
	(197, 'a3cb23fc-acd3-4ce0-8f36-1e5aa6a18432', 'U2', 'U2', 1976, NULL, NULL, NULL, NULL, NULL, 2, 103, NULL, 'Irish rock band', 0, '2018-01-27 02:00:25.755918+00', '0', 9622, NULL),
	(2107, '65314b12-0e08-43fa-ba33-baaa7b874c15', 'Leonard Cohen', 'Cohen, Leonard', 1934, 9, 21, 2016, 11, 7, 1, 38, 1, '', 0, '2016-11-12 16:00:39.937967+00', '1', 8532, 7703);
INSERT INTO musicbrainz.artist_credit (id, name, artist_count, gid, ref_count, created, edits_pending) VALUES
	(1, 'Various Artists', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7', 411397, '2011-05-16 16:32:11.963929+00', 0),
	(60, 'Tori Amos', 1, '3a7adaa9-535a-33e1-aa68-20a9ebfe2051', 13205, '2011-05-16 16:32:11.963929+00', 0),
	(2046742, 'Leonard Cohen feat. Tori Amos', 2, '3b46eb18-00e9-3078-b278-38694bd4d33c', 2, '2017-08-05 21:00:27.473927+00', 0),
	(2060761, 'U2 and Leonard Cohen', 2, '568fdfe4-9074-3e05-aad2-e3d19389b4a0', 3, '2017-08-30 21:57:51.926481+00', 0);
INSERT INTO musicbrainz.artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
	(1, 0, 1, 'Various Artists', ''),
	(60, 0, 60, 'Tori Amos', ''),
	(2046742, 0, 2107, 'Leonard Cohen', ' feat. '),
	(2046742, 1, 60, 'Tori Amos', ''),
	(2060761, 0, 197, 'U2', ' and '),
	(2060761, 1, 2107, 'Leonard Cohen', '');
INSERT INTO musicbrainz.release_group (id, gid, name, artist_credit, type, comment, edits_pending, last_updated) VALUES
	(1, 'd78c749c-432d-4fc9-b945-ab9b390ffe15', 'A', 60, NULL, '', 0, '2021-04-19 16:17:32.986082+00');
INSERT INTO musicbrainz.release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode, comment, edits_pending, quality, last_updated) VALUES
	(1, 'db1eeec5-7ffb-4bcc-8fbd-ea7ec0992a2d', 'A', 60, 1, NULL, NULL, NULL, NULL, NULL, '', 0, -1, '2021-04-19 16:17:32.986082+00');
INSERT INTO musicbrainz.label (id, gid, name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, label_code, type, area, comment, edits_pending, last_updated, ended) VALUES
	(95, '49b58bdb-3d74-40c6-956a-4c4b46115c9c', 'Virgin', 1973, NULL, NULL, NULL, NULL, NULL, 3098, 9, 240, 'worldwide imprint of Virgin Records Ltd. and all its subsidiaries', 0, '2021-02-07 06:00:18.894369+00', '0'),
	(235, '011d1192-6f65-45bd-85c4-0400dd45693e', 'Columbia', 1887, NULL, NULL, NULL, NULL, NULL, 162, 9, 222, 'imprint owned by CBS between 1938–1990 within US/CA/MX; owned worldwide by Sony Music Entertainment since 1991 except in JP', 0, '2020-10-27 04:00:23.905538+00', '0');
