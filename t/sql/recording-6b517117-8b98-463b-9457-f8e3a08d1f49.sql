-- Automatically generated, do not edit.

SET client_min_messages TO 'warning';

-- Temporarily drop triggers.
DROP TRIGGER deny_deprecated ON link;

INSERT INTO area (begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_date_day, end_date_month, end_date_year, ended, gid, id, last_updated, name, type) VALUES
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', '29a709d8-0320-493e-8d0c-f2c386662b7f', 5099, '2013-05-24 20:27:13.405462+00', 'Chicago', 3),
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', 'e638d120-090e-40f9-b021-6931f4c18b0d', 80722, '2013-12-01 12:55:30.407188+00', 'Olympia Fields', 3);
INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
	(80722, 5099, 8, 1, 1967, '', 0, NULL, NULL, NULL, NULL, '0', 1, 'c2d25856-a09a-4d15-b404-77dd19c19e63', 2884, '2015-07-12 04:00:17.463554+00', 'R. Kelly', 'Kelly, R.', 1);
INSERT INTO artist_alias (artist, begin_date_day, begin_date_month, begin_date_year, edits_pending, end_date_day, end_date_month, end_date_year, ended, id, last_updated, locale, name, primary_for_locale, sort_name, type) VALUES
	(2884, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 49093, '2012-06-04 19:17:07.562003+00', NULL, 'Robert Sylvester Kelly', '0', 'Robert Sylvester Kelly', 2),
	(2884, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 1818, '2012-05-15 18:57:13.252186+00', NULL, 'R.Kelly', '0', 'R.Kelly', NULL),
	(2884, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 3961, '2012-05-15 18:57:13.252186+00', NULL, 'R-Kelly', '0', 'R-Kelly', NULL),
	(2884, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 25017, '2012-05-15 18:57:13.252186+00', NULL, 'Kelly, R.', '0', 'Kelly, R.', NULL),
	(2884, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 28288, '2012-05-15 18:57:13.252186+00', NULL, 'R Kelly', '0', 'R Kelly', NULL),
	(2884, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 163, '2012-05-15 18:57:13.252186+00', NULL, 'R Kelly', '0', 'R Kelly', NULL),
	(2884, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 8162, '2012-05-15 18:57:13.252186+00', NULL, 'R. Kellly', '0', 'R. Kellly', NULL);
INSERT INTO tag (id, name, ref_count) VALUES
	(19, 'pop', 21043),
	(111, 'american', 2199),
	(150, 'hip-hop', 9611),
	(609, 'soul', 4480),
	(657, 'rnb', 261),
	(1182, 'pop rap', 551),
	(1208, 'neo soul', 65),
	(1280, 'new jack swing', 33),
	(4667, 'hip hop rnb and dance hall', 664),
	(40661, 'r&b', 0),
	(41027, 'contemporary r&b', 0);
INSERT INTO artist_tag (artist, count, last_updated, tag) VALUES
	(2884, 1, '2011-05-16 14:57:06.530063+00', 19),
	(2884, 1, '2011-05-16 14:57:06.530063+00', 111),
	(2884, 1, '2011-05-16 14:57:06.530063+00', 150),
	(2884, 1, '2011-05-16 14:57:06.530063+00', 609),
	(2884, 1, '2011-05-16 14:57:06.530063+00', 657),
	(2884, 1, '2011-05-16 14:57:06.530063+00', 1182),
	(2884, 1, '2011-05-16 14:57:06.530063+00', 1208),
	(2884, 1, '2011-05-16 14:57:06.530063+00', 1280),
	(2884, 1, '2011-05-16 14:57:06.530063+00', 4667),
	(2884, 1, '2014-07-08 17:39:36.019133+00', 40661),
	(2884, 1, '2014-07-08 17:39:36.019133+00', 41027);
INSERT INTO artist_credit (artist_count, created, id, name, ref_count, gid) VALUES
	(1, '2011-05-16 16:32:11.963929+00', 2884, 'R. Kelly', 3368, 'ae53b19f-b260-31a8-8d0a-d475c62221be');
INSERT INTO artist_credit_name (artist, artist_credit, join_phrase, name, position) VALUES
	(2884, 2884, '', 'R. Kelly', 0);
INSERT INTO recording (artist_credit, comment, edits_pending, gid, id, last_updated, length, name, video) VALUES
	(2884, '', 0, '6b517117-8b98-463b-9457-f8e3a08d1f49', 9042322, '2014-04-19 09:21:02.680799+00', 277773, 'The World''s Greatest', '0');
INSERT INTO isrc (created, edits_pending, id, isrc, recording, source) VALUES
	('2012-12-02 00:45:39.212937+00', 0, 348424, 'USJI10100576', 9042322, NULL);
INSERT INTO area (begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_date_day, end_date_month, end_date_year, ended, gid, id, last_updated, name, type) VALUES
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', '2dd47a64-91d5-3b13-bc94-80043ed063d7', 106, '2013-05-27 12:32:31.072979+00', 'Jamaica', 1),
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', '489ce91b-6658-3307-9877-795b68554c98', 222, '2013-06-15 18:06:39.59323+00', 'United States', 1),
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', 'b03ff310-d8e2-45cf-9455-769f76641eb2', 5179, '2013-11-01 03:49:29.251418+00', 'Detroit', 3);
INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
	(106, NULL, NULL, NULL, 1944, '', 0, NULL, NULL, NULL, NULL, '0', 1, '4936b50e-7c5b-4a9d-a900-37a19cb3ae1d', 170973, '2015-06-12 05:10:00.501701+00', 'Glen Brown', 'Brown, Glen', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, '2685f339-b559-4a99-b0a1-d16d3506de64', 288223, NULL, 'Peter Mokran', 'Mokran, Peter', 1),
	(222, 5179, 15, 8, 1936, '', 0, NULL, NULL, NULL, NULL, '0', 1, '2387a257-4b30-4af0-af33-d7e5eaa0b5f9', 379302, '2013-12-18 06:28:44.673939+00', 'Paul Riser', 'Riser, Paul', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, '5f906ee6-fc04-4e90-8141-66f32e5da3cf', 390124, NULL, 'Walt Whitman & The Soul Children of Chicago', 'Whitman, Walt & Soul Children of Chicago, The', 2),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, '0a51af30-5e31-470e-abd2-dd979a3e3d80', 440725, NULL, 'Donnie Lyle', 'Lyle, Donnie', 1),
	(222, NULL, NULL, NULL, NULL, 'engineer', 0, NULL, NULL, NULL, NULL, '0', 1, '8776dceb-4d56-418d-b33a-fc0e6a14e46c', 454065, '2015-02-15 05:08:17.966667+00', 'Tony Flores', 'Flores, Tony', 1),
	(222, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', 1, 'c84ebed5-c70c-454f-9a66-31030d311e75', 577397, '2013-11-26 22:19:23.539734+00', 'Hart Hollman', 'Hollman, Hart', 1),
	(5179, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, 'eb65b73a-00f8-475b-beb4-a09cf5cd7a00', 577400, '2013-11-26 22:57:48.557543+00', 'The Motown Romance Orchestra', 'Motown Romance Orchestra, The', 2),
	(5179, NULL, NULL, NULL, NULL, 'US bassist, guitarist & recording engineer', 0, NULL, NULL, NULL, NULL, '0', 1, '95c05e60-c473-4e2e-b175-9e43b006c036', 577402, '2013-11-26 22:55:29.660617+00', 'Carl Robinson', 'Robinson, Carl', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, '134d3aac-76f7-4652-993e-932d01256d49', 590249, '2009-01-20 18:38:51.605026+00', 'Yvonne Gage', 'Gage, Yvonne', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, 'b7ce9a76-0abc-4f3a-b841-4a7b06f56268', 617105, '2009-05-15 05:05:59.581244+00', 'Joan Collaso', 'Collaso, Joan', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, '99c9d990-6b02-4600-93a2-66ff9c078f34', 658294, '2009-11-16 01:40:18.646785+00', 'Robin Robinson', 'Robinson, Robin', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, 'ad8f6a75-ca4c-4455-a3eb-cecb6b97d484', 721637, '2010-06-03 19:03:56.278125+00', 'Juan Pablo Negrete Ortiz', 'Ortiz, Juan Pablo Negrete', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, '76c26a5b-2f2f-4bdd-bb7a-5a62d9d3e6ef', 746894, '2010-09-22 13:04:02.323676+00', 'Ian Mereness', 'Mereness, Ian', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, 'ac6bd6c5-dab1-4b55-9842-4a8945dedfea', 746895, '2010-09-22 13:05:42.776534+00', 'Abel Garibaldi', 'Garibaldi, Abel', 1),
	(222, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, '1b300c2c-c133-4d1a-b048-fd37f4d91034', 746896, '2012-05-24 10:34:54.684169+00', 'Andy Gallas', 'Gallas, Andy', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, '19c882f5-a6ec-488f-b6ad-ab489eddc655', 746942, '2010-09-22 19:26:03.973056+00', 'Kendall Nesbitt', 'Nesbitt, Kendall', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', 1, 'c7ea517c-efbb-453b-abd2-5e368f6e5475', 811713, '2011-06-22 23:13:04.395625+00', 'John Rutledge', 'Rutledge, John', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', 1, '2373f554-6a1e-46f9-bac2-8bab5e86b7de', 949261, '2012-12-02 15:40:26.709946+00', 'Percy Bady', 'Bady, Percy', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', 1, '2c92addd-868b-4c3c-b886-0ed7a6ee3a6b', 949262, '2012-12-02 15:41:30.062083+00', 'Jeffrey W. Morrow', 'Morrow, Jeffrey W.', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', 2, '001363e3-f643-4aca-bb95-3075cdcf62c8', 949263, '2012-12-02 15:43:17.170164+00', 'Lori Holton-Nash', 'Holton-Nash, Lori', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', 2, '273d6cda-312f-41fa-bf7e-837d51181172', 949264, '2012-12-02 15:44:34.215648+00', 'Felicia Coleman-Evans', 'Coleman-Evans, Felicia', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', 2, '3de09330-f53d-4faa-ae92-726866ab9c96', 949265, '2012-12-02 15:45:47.762545+00', 'Deletrice Alexander', 'Alexander, Deletrice', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', NULL, 'f9231d98-6e7d-4afd-b2cf-9a656a260f85', 949266, '2012-12-02 15:46:52.515471+00', 'Simbryt Whittington', 'Whittington, Simbryt', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', 1, '690d39ad-7512-4abd-82b8-1885ed255a4b', 949267, '2012-12-02 15:48:15.297084+00', 'Paul Mabin', 'Mabin, Paul', 1),
	(NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, NULL, '0', 1, '99e6b7b6-c97d-4781-aed6-510cd6711092', 949268, '2012-12-02 15:51:48.333555+00', 'Greg Calvert', 'Calvert, Greg', 1),
	(222, NULL, NULL, NULL, NULL, 'US choir vocals', 0, NULL, NULL, NULL, NULL, '0', 1, '1c7a3225-2c5a-402e-a988-786b06ef5013', 970302, '2013-01-27 01:02:32.551359+00', 'Steve Robinson', 'Robinson, Steve', 1);
INSERT INTO artist_alias (artist, begin_date_day, begin_date_month, begin_date_year, edits_pending, end_date_day, end_date_month, end_date_year, ended, id, last_updated, locale, name, primary_for_locale, sort_name, type) VALUES
	(170973, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 161956, '2015-06-17 19:42:36.958659+00', NULL, 'The Rhythm Master', '0', 'Rhythm Master, The', NULL),
	(170973, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 161606, '2015-06-12 05:09:31.254816+00', NULL, 'Glenmore Lloyd Brown', '0', 'Brown, Glenmore Lloyd', 2),
	(170973, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 96802, '2012-05-15 18:57:13.252186+00', NULL, 'Glen L. Brown', '0', 'Glen L. Brown', NULL),
	(170973, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 161955, '2015-06-17 19:41:39.903069+00', NULL, 'God Son', '0', 'God Son', NULL),
	(379302, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 141992, '2013-12-18 06:28:44.673939+00', NULL, 'Paul Leonidas Riser', '0', 'Riser, Paul Leonidas', 2),
	(379302, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 156895, '2015-01-29 14:32:42.304195+00', NULL, 'Riser', '0', 'Riser', NULL);
INSERT INTO tag (id, name, ref_count) VALUES
	(4668, 'soul and reggae', 589);
INSERT INTO artist_tag (artist, count, last_updated, tag) VALUES
	(170973, 1, '2011-05-16 14:57:06.530063+00', 4668);
INSERT INTO link (attribute_count, begin_date_day, begin_date_month, begin_date_year, created, end_date_day, end_date_month, end_date_year, ended, id, link_type) VALUES
	(1, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 12736, 156),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 12737, 141),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 12746, 151),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 12759, 150),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 12768, 143),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 12772, 128),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 12773, 297),
	(1, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 12783, 148),
	(2, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 12813, 148),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 12872, 132),
	(1, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 12920, 149),
	(1, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 13064, 128),
	(2, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 13559, 158),
	(1, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 13841, 143),
	(1, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 20950, 132),
	(0, NULL, NULL, NULL, '2011-11-29 07:02:36.129638+00', NULL, NULL, NULL, '0', 32089, 300),
	(2, NULL, NULL, NULL, '2012-12-02 11:52:39.998293+00', NULL, NULL, NULL, '0', 89710, 143);
INSERT INTO link_attribute (attribute_type, created, link) VALUES
	(1, '2011-05-16 15:03:23.368437+00', 12736),
	(75, '2011-05-16 15:03:23.368437+00', 12783),
	(1, '2011-05-16 15:03:23.368437+00', 12813),
	(232, '2011-05-16 15:03:23.368437+00', 12813),
	(13, '2011-05-16 15:03:23.368437+00', 12920),
	(1, '2011-05-16 15:03:23.368437+00', 13064),
	(40, '2011-05-16 15:03:23.368437+00', 13559),
	(69, '2011-05-16 15:03:23.368437+00', 13559),
	(424, '2011-05-16 15:03:23.368437+00', 13841),
	(526, '2011-05-16 15:03:23.368437+00', 20950),
	(424, '2012-12-02 11:52:39.998293+00', 89710),
	(526, '2012-12-02 11:52:39.998293+00', 89710);
INSERT INTO l_artist_recording (edits_pending, entity0, entity0_credit, entity1, entity1_credit, id, last_updated, link, link_order) VALUES
	(0, 2884, '', 9042322, '', 1480543, '2012-12-02 00:43:00.557448+00', 12737, 0),
	(0, 2884, '', 9042322, '', 1480544, '2012-12-02 00:43:00.557448+00', 12773, 0),
	(0, 440725, '', 9042322, '', 1482962, '2012-12-02 15:56:08.989959+00', 12783, 0),
	(0, 2884, '', 9042322, '', 1482963, '2012-12-02 15:56:08.989959+00', 13841, 0),
	(0, 379302, '', 9042322, '', 1482964, '2012-12-02 15:56:08.989959+00', 13559, 0),
	(0, 379302, '', 9042322, '', 1482965, '2012-12-02 15:56:08.989959+00', 12746, 0),
	(0, 379302, '', 9042322, '', 1482966, '2012-12-02 15:56:08.989959+00', 32089, 0),
	(0, 577397, '', 9042322, '', 1482967, '2012-12-02 15:56:08.989959+00', 12736, 0),
	(0, 577400, '', 9042322, '', 1482968, '2014-01-15 15:29:44.683048+00', 12759, 0),
	(0, 746942, '', 9042322, '', 1482969, '2012-12-02 15:56:08.989959+00', 12813, 0),
	(0, 949261, '', 9042322, '', 1482970, '2012-12-02 15:56:08.989959+00', 12813, 0),
	(0, 949262, '', 9042322, '', 1482971, '2012-12-02 15:56:08.989959+00', 12920, 0),
	(0, 658294, '', 9042322, '', 1482972, '2012-12-02 15:56:08.989959+00', 12920, 0),
	(0, 970302, '', 9042322, '', 1482973, '2013-01-27 01:02:54.844992+00', 12920, 0),
	(0, 949263, '', 9042322, '', 1482974, '2012-12-02 15:56:08.989959+00', 12920, 0),
	(0, 949264, '', 9042322, '', 1482975, '2012-12-02 15:56:08.989959+00', 12920, 0),
	(0, 617105, '', 9042322, '', 1482976, '2012-12-02 15:56:08.989959+00', 12920, 0),
	(0, 949265, '', 9042322, '', 1482977, '2012-12-02 15:56:08.989959+00', 12920, 0),
	(0, 590249, '', 9042322, '', 1482978, '2012-12-02 15:56:08.989959+00', 12920, 0),
	(0, 949266, '', 9042322, '', 1482979, '2012-12-02 15:56:08.989959+00', 12920, 0),
	(0, 811713, '', 9042322, '', 1482980, '2012-12-02 15:56:08.989959+00', 12920, 0),
	(0, 949267, '', 9042322, '', 1482981, '2012-12-02 15:56:08.989959+00', 12920, 0),
	(0, 390124, '', 9042322, '', 1482982, '2012-12-02 15:56:08.989959+00', 12920, 0),
	(0, 746895, '', 9042322, '', 1482983, '2012-12-02 15:56:08.989959+00', 12772, 0),
	(0, 746894, '', 9042322, '', 1482984, '2012-12-02 15:56:08.989959+00', 12772, 0),
	(0, 577402, '', 9042322, '', 1482985, '2012-12-02 15:56:08.989959+00', 13064, 0),
	(0, 746895, '', 9042322, '', 1482986, '2012-12-02 15:56:08.989959+00', 12872, 0),
	(0, 746894, '', 9042322, '', 1482987, '2012-12-02 15:56:08.989959+00', 12872, 0),
	(0, 746896, '', 9042322, '', 1482988, '2012-12-02 15:56:08.989959+00', 20950, 0),
	(0, 721637, '', 9042322, '', 1482989, '2012-12-02 15:56:08.989959+00', 20950, 0),
	(0, 949268, '', 9042322, '', 1482990, '2012-12-02 15:56:08.989959+00', 20950, 0),
	(0, 170973, '', 9042322, '', 1482991, '2012-12-02 15:56:08.989959+00', 20950, 0),
	(0, 288223, '', 9042322, '', 1482992, '2012-12-02 15:56:08.989959+00', 12768, 0),
	(0, 454065, '', 9042322, '', 1482993, '2012-12-02 15:56:08.989959+00', 89710, 0);
INSERT INTO label (area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_date_day, end_date_month, end_date_year, ended, gid, id, label_code, last_updated, name, type) VALUES
	(222, NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', 'f1d83aa8-7830-4aa6-906f-ac19d8862155', 50885, NULL, '2013-06-08 10:00:17.430564+00', 'R. Kelly Publishing Inc.', 7);
INSERT INTO link (attribute_count, begin_date_day, begin_date_month, begin_date_year, created, end_date_day, end_date_month, end_date_year, ended, id, link_type) VALUES
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 26980, 206);
INSERT INTO l_label_recording (edits_pending, entity0, entity0_credit, entity1, entity1_credit, id, last_updated, link, link_order) VALUES
	(0, 50885, '', 9042322, '', 5809, '2012-12-02 15:29:08.249644+00', 26980, 0);
INSERT INTO work (comment, edits_pending, gid, id, last_updated, name, type) VALUES
	('', 0, '2025da95-23f1-31ae-b991-088834e6ce2f', 1231902, '2013-02-08 15:00:27.344797+00', 'The World''s Greatest', 17);
INSERT INTO work_language (language, work) VALUES
	(120, 1231902);
INSERT INTO tag (id, name, ref_count) VALUES
	(69142, 'positive affirmations', 0);
INSERT INTO work_tag (count, last_updated, tag, work) VALUES
	(1, '2014-07-08 13:38:56.993444+00', 69142, 1231902);
INSERT INTO link (attribute_count, begin_date_day, begin_date_month, begin_date_year, created, end_date_day, end_date_month, end_date_year, ended, id, link_type) VALUES
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 27124, 278);
INSERT INTO l_recording_work (edits_pending, entity0, entity0_credit, entity1, entity1_credit, id, last_updated, link, link_order) VALUES
	(0, 9042322, '', 1231902, '', 803122, '2013-02-08 15:00:27.344797+00', 27124, 0);

-- Restore triggers.
CREATE TRIGGER deny_deprecated BEFORE UPDATE OR INSERT ON link FOR EACH ROW EXECUTE PROCEDURE deny_deprecated_links();
