-- Automatically generated, do not edit.
-- release 765435fa-1e6e-40aa-bef2-2d09f367ef44 142015fb-3775-4b25-9d4a-51e0bd289ef4

SET client_min_messages TO 'warning';

-- Temporarily drop triggers.
DROP TRIGGER deny_deprecated ON link;

INSERT INTO area (begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_date_day, end_date_month, end_date_year, ended, gid, id, last_updated, name, type) VALUES
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', '71bbafaa-e825-3e15-8ca9-017dcad1748b', 38, '2013-05-27 13:15:52.179105+00', 'Canada', 1),
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', 'bbc88d72-1f32-4936-8dc6-b62b3318e1c4', 5107, '2013-05-24 20:28:52.632131+00', 'Ottawa', 3);
INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
	(38, 5107, 30, 7, 1941, '', 0, NULL, NULL, NULL, NULL, '0', 1, '420c6768-0885-415a-bb59-d6a275121125', 11617, '2013-07-12 03:53:14.46208+00', 'Paul Anka', 'Anka, Paul', 1);
INSERT INTO artist_credit (artist_count, created, id, name, ref_count, gid) VALUES
	(1, '2011-05-16 16:32:11.963929+00', 11617, 'Paul Anka', 3011, 'e1d4e43b-0a0d-302c-be90-8a23bd2c7e27');
INSERT INTO artist_credit_name (artist, artist_credit, join_phrase, name, position) VALUES
	(11617, 11617, '', 'Paul Anka', 0);
INSERT INTO release_group (artist_credit, comment, edits_pending, gid, id, last_updated, name, type) VALUES
	(11617, '', 0, '51538135-0d1c-31a7-852e-ea5dd0c72d4d', 71076, '2015-10-29 21:00:55.471066+00', 'Diana', NULL);
INSERT INTO release (artist_credit, barcode, comment, edits_pending, gid, id, language, last_updated, name, packaging, quality, release_group, script, status) VALUES
	(11617, NULL, '', 1, '142015fb-3775-4b25-9d4a-51e0bd289ef4', 1231807, NULL, '2015-10-29 21:00:55.471066+00', 'Diana', NULL, -1, 71076, 28, NULL),
	(11617, NULL, '', 1, '765435fa-1e6e-40aa-bef2-2d09f367ef44', 1231808, NULL, '2015-10-26 20:04:18.393064+00', 'Diana', NULL, -1, 71076, 28, NULL);
INSERT INTO medium (edits_pending, format, id, gid, last_updated, name, position, release, track_count) VALUES
	(0, 1, 1260623, '9bd7643c-52f9-4114-9f46-98a56963f7f7', '2012-12-17 00:04:14.60624+00', '', 1, 1231807, 18),
	(0, 1, 1260624, 'bf0c7dfa-6bf1-4fa9-a404-c58dcd936d31', '2012-12-17 00:07:47.571271+00', '', 1, 1231808, 18);
INSERT INTO recording (artist_credit, comment, edits_pending, gid, id, last_updated, length, name, video) VALUES
	(11617, '', 0, '8289ea80-fa72-4af3-9f7b-a711791e6fe8', 518579, '2015-10-26 04:03:35.419964+00', 140666, 'Diana', '0'),
	(11617, '', 0, '6e78e763-2ddd-4b01-847f-32b1982026b4', 518580, '2015-10-26 20:04:19.620173+00', 145066, 'Lonely Boy', '0'),
	(11617, '', 0, 'ddae7f28-9568-4fd1-8244-901c99df65d6', 518581, '2015-10-04 10:01:24.55817+00', 148666, 'You Are My Destiny', '0'),
	(11617, '', 0, '0c0abf9c-4cde-4690-b14f-54953fccb118', 518584, '2015-10-26 20:04:18.717452+00', 147000, 'Crazy Love', '0'),
	(11617, '', 0, 'c7fbc0bc-bfb8-44f4-b713-4f1c0552e98e', 518585, '2015-10-04 14:01:09.639552+00', 165000, 'Puppy Love', '0'),
	(11617, '', 0, 'c7e5724c-b908-4c44-abd5-e376f9bb752f', 518586, '2015-10-12 03:02:07.5515+00', 156026, 'Put Your Head on My Shoulder', '0'),
	(11617, '', 0, '2449502e-ec6d-480b-85db-0ca76c9fc323', 518587, '2015-10-26 20:04:20.16155+00', 143426, 'I Love You Baby', '0'),
	(11617, '', 0, 'b6e2e871-9759-4fe0-b121-9ef2ab93e966', 518588, '2015-10-26 20:04:20.844449+00', 144173, 'It''s Time to Cry', '0'),
	(11617, '', 0, '162c392c-1801-49b4-b2ea-da8bac1b8278', 518590, '2015-10-26 20:04:21.900369+00', 126866, 'My Home Town', '0'),
	(11617, '', 0, '0a6096b4-9397-4602-9deb-9d72fb1a7732', 518591, '2015-10-26 20:04:22.59541+00', 123200, 'Cinderella', '0'),
	(11617, '', 0, '5ef725d3-ccbf-421b-8a9a-0469e67f962a', 518593, '2015-10-31 20:04:10.87106+00', 127400, 'Tonight My Love, Tonight', '0'),
	(11617, '', 0, '527d991b-38d0-479b-970d-2a95de8d515e', 518594, '2015-10-26 20:04:21.381225+00', 147640, 'Don''t Gamble With Love', '0'),
	(11617, '', 0, '1afccd95-c811-49d1-838c-4cca7e94d943', 1769008, '2015-10-03 20:00:47.613869+00', 150200, 'Time to Cry', '0'),
	(11617, '', 0, '2f788cc6-94e8-4738-b191-dcc44400626d', 1769010, '2015-10-03 20:00:48.445068+00', 148066, 'I Love You in the Same Old Way', '0'),
	(11617, '', 0, '7603d9a1-16ac-4030-8915-3745aef37779', 1769019, '2015-10-03 20:00:50.130837+00', 109334, 'It Doesn''t Matter Anymore', '0'),
	(11617, '', 0, 'fa4496a3-b0e6-424d-b031-e7e37cf36401', 14317504, '2015-10-22 20:16:15.116558+00', 147960, 'Lonely Boy', '0'),
	(11617, '', 0, '9598e1d8-32a3-4ab9-b5fa-99f38c73082b', 14317507, '2015-10-22 20:16:15.116558+00', 143573, 'It’s Time to Cry', '0'),
	(11617, '', 0, '160485f8-88c5-4af4-a863-8eddc46e858e', 14317508, '2012-12-17 00:04:11.665592+00', 108000, 'When I Stop Loving You', '0'),
	(11617, '', 0, 'c961c3f6-5668-43e0-945b-8003d859acf0', 14317510, '2015-10-22 20:16:15.116558+00', 147600, 'It Doesn’t Matter Anymore', '0'),
	(11617, '', 0, '24edcece-38e7-4193-8d5c-4948f66620fc', 14317511, '2012-12-17 00:04:11.665592+00', 112333, 'Midnight', '0'),
	(11617, '', 0, '1ab4c373-d305-4795-a8c5-fbe6a630d5d1', 14317512, '2015-10-22 20:16:15.116558+00', 114533, 'Time to Cry', '0'),
	(11617, '', 0, 'e14b5cb9-f8c5-45f8-a6d5-ba0fd4f62b08', 14317513, '2012-12-17 00:04:11.665592+00', 150240, 'The Longest Day', '0'),
	(11617, '', 0, '89481e2a-368e-4ca8-86ba-8bdc2b3c55b7', 14317516, '2015-10-22 20:16:15.116558+00', 129306, 'I Love You in the Same Old Way', '0'),
	(11617, '', 0, '3db52702-8df2-40b4-a189-84a4e6fb95b7', 14317517, '2015-10-22 20:16:15.116558+00', 149293, 'I Love in the Same Old Way', '0'),
	(11617, '', 0, 'ed83d825-391a-4556-a373-7d0e8f1fcf1c', 14317526, '2012-12-17 00:07:46.870065+00', 107800, 'When I Stop Loving You', '0'),
	(11617, '', 0, 'a8961ceb-ef8d-419b-a408-b58740724939', 14317530, '2012-12-17 00:07:46.870065+00', 114000, 'Midnight', '0'),
	(11617, '', 0, 'e8b9bda4-f166-4a1d-bd0c-1a39d30376f1', 14317532, '2012-12-17 00:07:46.870065+00', 124800, 'The Longest Day', '0');
INSERT INTO track (artist_credit, edits_pending, gid, id, is_data_track, last_updated, length, medium, name, number, position, recording) VALUES
	(11617, 0, '6284aa85-9e55-325a-acdc-6f4b768fb488', 13806022, '0', '2015-10-26 20:04:20.16155+00', 143426, 1260623, 'I Love You Baby', '6', 6, 518587),
	(11617, 0, 'e101f21a-1d89-3061-8420-98c5c8e3462b', 13806032, '0', '2015-10-22 20:16:15.116558+00', 129306, 1260623, 'I Love You in the Same Old Way', '16', 16, 14317516),
	(11617, 0, 'e3a5ec4e-e5ec-3d0e-855d-36e16e03cc48', 13806020, '0', '2015-10-22 20:16:15.116558+00', 147960, 1260623, 'Lonely Boy', '4', 4, 14317504),
	(11617, 0, 'a4ef2d76-8c8a-3cae-a3c8-bd5ed80667ed', 13806023, '0', '2015-10-22 20:16:15.116558+00', 143573, 1260623, 'It’s Time to Cry', '7', 7, 14317507),
	(11617, 0, 'c4299065-a9da-399c-ab72-ec87f3a565ad', 13806021, '0', '2015-10-22 20:16:15.116558+00', 167573, 1260623, 'Puppy Love', '5', 5, 518585),
	(11617, 0, 'da6041c3-8f1d-3bd2-96bb-325a52eb6952', 13806029, '0', '2015-10-22 20:16:15.116558+00', 150240, 1260623, 'The Longest Day', '13', 13, 14317513),
	(11617, 0, '9fe83668-b5f8-3b7f-9ee1-0bd977ab1c88', 13806030, '0', '2015-10-26 20:04:21.900369+00', 125160, 1260623, 'My Hometown', '14', 14, 518590),
	(11617, 0, '55756ddf-994f-3f3f-b7d5-46d0b72e6c26', 13806017, '0', '2015-10-22 20:16:15.116558+00', 139640, 1260623, 'Diana', '1', 1, 518579),
	(11617, 0, 'b43286ba-18b2-35b7-aaed-d648b19af8ce', 13806026, '0', '2015-10-22 20:16:15.116558+00', 147600, 1260623, 'It Doesn’t Matter Anymore', '10', 10, 14317510),
	(11617, 0, '739366a8-97b6-3847-94fb-bd069e787323', 13806028, '0', '2015-10-22 20:16:15.116558+00', 114533, 1260623, 'Time to Cry', '12', 12, 14317512),
	(11617, 0, '8b572d87-b534-3b65-a4c6-639144fd7b4c', 13806033, '0', '2015-10-22 20:16:15.116558+00', 149293, 1260623, 'I Love in the Same Old Way', '17', 17, 14317517),
	(11617, 0, 'b6475023-d337-3095-8125-72efdaf2df90', 13806034, '0', '2015-10-26 20:04:22.59541+00', 125173, 1260623, 'Cinderella', '18', 18, 518591),
	(11617, 0, '5c439fc2-bdd7-33cb-b5ea-3f47d73ed6a6', 13806019, '0', '2015-10-26 20:04:18.717452+00', 147906, 1260623, 'Crazy Love', '3', 3, 518584),
	(11617, 0, 'd4595c0a-1357-303c-bc17-080f74a51c41', 13806031, '0', '2015-10-31 20:04:10.87106+00', 127400, 1260623, 'Tonight My Love, Tonight', '15', 15, 518593),
	(11617, 0, '4910f11b-5628-3654-849a-08e74dc34bc4', 13806024, '0', '2015-10-22 20:16:15.116558+00', 108000, 1260623, 'When I Stop Loving You', '8', 8, 14317508),
	(11617, 0, 'beae8496-cc31-3f73-81bb-cd63873619b3', 13806025, '0', '2015-10-22 20:16:15.116558+00', 155560, 1260623, 'Put Your Head on My Shoulder', '9', 9, 518586),
	(11617, 0, '0044a38b-1fad-32d6-b408-0e5aba8242c1', 13806027, '0', '2015-10-22 20:16:15.116558+00', 112333, 1260623, 'Midnight', '11', 11, 14317511),
	(11617, 0, '5db0b7f7-e6a0-3584-9cd9-9425eacd355f', 13806018, '0', '2015-10-22 20:16:15.116558+00', 149893, 1260623, 'You Are My Destiny', '2', 2, 518581),
	(11617, 0, '332455dd-0ebe-3c67-ba57-1fb06cb64324', 13806056, '0', '2015-10-26 20:04:22.59541+00', 124106, 1260624, 'Cinderella', '18', 18, 518591),
	(11617, 0, '83194b95-11fd-380a-bdac-4ee19a4113ff', 13806055, '0', '2015-10-03 20:00:48.445068+00', 149000, 1260624, 'I Love You In The Same Old Way', '17', 17, 1769010),
	(11617, 0, '68a98cd7-14a8-370e-a8b1-62c1d1788667', 13806040, '0', '2015-10-03 20:00:48.844685+00', 148400, 1260624, 'You Are My Destiny', '2', 2, 518581),
	(11617, 0, 'fb26602d-dd8f-35f6-a323-d959ab1d9690', 13806047, '0', '2015-10-03 20:00:47.178018+00', 155693, 1260624, 'Put Your Head On My Shoulder', '9', 9, 518586),
	(11617, 0, 'f7dfc371-f233-35fc-bb37-3d74e70ac14c', 13806044, '0', '2015-10-26 20:04:20.16155+00', 143226, 1260624, 'I Love You Baby', '6', 6, 518587),
	(11617, 0, 'b0262db9-4a31-39b3-833c-6a6a89889248', 13806054, '0', '2015-10-31 20:04:10.87106+00', 129000, 1260624, 'Tonight My Love, Tonight', '16', 16, 518593),
	(11617, 0, 'c8417f8e-f01b-3d25-9533-848d3229230a', 13806039, '0', '2015-10-03 20:00:46.637053+00', 141440, 1260624, 'Diana', '1', 1, 518579),
	(11617, 0, 'db4cfd50-7d80-3fdf-91b4-cd7edf1767b2', 13806051, '0', '2015-10-03 20:00:47.613869+00', 150200, 1260624, 'Time To Cry', '13', 13, 1769008),
	(11617, 0, '75edf22d-30a5-353f-b811-1c2bf46b3579', 13806046, '0', '2012-12-17 00:07:46.870065+00', 107800, 1260624, 'When I Stop Loving You', '8', 8, 14317526),
	(11617, 0, 'eabc71ca-c518-3f88-9761-e84239a39045', 13806050, '0', '2012-12-17 00:07:46.870065+00', 114000, 1260624, 'Midnight', '12', 12, 14317530),
	(11617, 0, '23b7a81b-584f-3e2e-955d-b1daab90254a', 13806045, '0', '2015-10-26 20:04:20.844449+00', 144173, 1260624, 'It''s Time To Cry', '7', 7, 518588),
	(11617, 0, '17ec625e-1270-38d1-b89a-f65480b4dd97', 13806049, '0', '2015-10-03 20:00:50.130837+00', 111893, 1260624, 'It Doesn''t Matter Anymore', '11', 11, 1769019),
	(11617, 0, '0999afe8-5ca9-3e6c-8907-e8a6e01f0067', 13806043, '0', '2015-10-03 20:00:48.045003+00', 166040, 1260624, 'Puppy Love', '5', 5, 518585),
	(11617, 0, 'a62b7eb4-99a0-3c0d-a9f7-8042e8fdf175', 13806041, '0', '2015-10-26 20:04:18.717452+00', 148866, 1260624, 'Crazy Love', '3', 3, 518584),
	(11617, 0, '3e5794e1-9344-3281-a6b8-abeabd96f913', 13806052, '0', '2012-12-17 00:07:46.870065+00', 124800, 1260624, 'The Longest Day', '14', 14, 14317532),
	(11617, 0, 'a26e6cc2-40cd-36f4-8a7a-1fc1c1012def', 13806042, '0', '2015-10-26 20:04:19.620173+00', 148693, 1260624, 'Lonely Boy', '4', 4, 518580),
	(11617, 0, '4d1e82a5-9238-37d9-9f82-81ece37dc854', 13806048, '0', '2015-10-26 20:04:21.381225+00', 148773, 1260624, 'Don''t Gamble With Love', '10', 10, 518594),
	(11617, 0, '1bcc7594-9536-3691-ae28-6cea129fa34c', 13806053, '0', '2015-10-26 20:04:21.900369+00', 128466, 1260624, 'My Hometown', '15', 15, 518590);

-- Restore triggers.
CREATE TRIGGER deny_deprecated BEFORE UPDATE OR INSERT ON link FOR EACH ROW EXECUTE PROCEDURE deny_deprecated_links();
