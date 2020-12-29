-- Automatically generated, do not edit.

SET client_min_messages TO 'warning';

-- Temporarily drop triggers.
DROP TRIGGER deny_deprecated ON link;

INSERT INTO area (begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_date_day, end_date_month, end_date_year, ended, gid, id, last_updated, name, type) VALUES
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '1', '489ce91b-6658-3307-9877-795b68554c98', 222, '2015-09-22 21:21:30.007054-05', 'United States', 1),
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', 'e183ffae-1d35-4c78-b552-957535e40af1', 7324, '2013-05-28 07:01:33.74757-05', 'Long Beach', 3);
INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
	(222, 7324, 20, 10, 1971, '', 2, NULL, NULL, NULL, NULL, '0', 1, 'f90e8b26-9e52-4669-a5c9-e28529c47894', 177, '2015-01-12 17:02:55.86908-06', 'Snoop Dogg', 'Snoop Dogg', 1),
	(222, 7324, 20, 10, 1971, 'Snoop Dogg reggae side-project', 0, NULL, NULL, NULL, NULL, '0', 1, '960db060-0ba8-4f6c-9770-49b81dc6e5ea', 952603, '2014-03-18 01:33:31.763034-05', 'Snoop Lion', 'Snoop Lion', 1);
INSERT INTO artist_alias (artist, begin_date_day, begin_date_month, begin_date_year, edits_pending, end_date_day, end_date_month, end_date_year, ended, id, last_updated, locale, name, primary_for_locale, sort_name, type) VALUES
	(177, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 1943, '2012-05-15 13:57:13.252186-05', NULL, 'Snoop Doggy', '0', 'Snoop Doggy', NULL),
	(177, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 1459, '2012-05-15 13:57:13.252186-05', NULL, 'Snoop', '0', 'Snoop', NULL),
	(177, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 26487, '2012-05-15 13:57:13.252186-05', NULL, 'Snopp Dogg', '0', 'Snopp Dogg', NULL),
	(177, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 11896, '2012-05-15 13:57:13.252186-05', NULL, 'Snoog Dogg', '0', 'Snoog Dogg', NULL),
	(177, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 1461, '2012-05-15 13:57:13.252186-05', NULL, 'Snoop Doggy Dog', '0', 'Snoop Doggy Dog', NULL),
	(177, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 53964, '2012-05-15 13:57:13.252186-05', NULL, 'Big Snoop Dogg', '0', 'Big Snoop Dogg', NULL),
	(177, NULL, NULL, 1996, 0, NULL, 7, 2012, '1', 122472, '2012-08-08 17:47:29.575669-05', 'en', 'Snoop Dogg', '1', 'Snoop Dogg', 1),
	(177, NULL, NULL, NULL, 0, NULL, NULL, 1996, '1', 9982, '2012-08-08 17:47:29.575669-05', 'en', 'Snoop Doggy Dogg', '0', 'Snoop Doggy Dogg', 1);
INSERT INTO tag (id, name, ref_count) VALUES
	(111, 'american', 2199),
	(150, 'hip-hop', 9611),
	(235, 'hip hop', 3685),
	(267, 'reggae', 3145),
	(1175, 'gangsta rap', 132),
	(1176, 'west coast hip-hop', 3),
	(1225, 'g-funk', 6),
	(4667, 'hip hop rnb and dance hall', 664);
INSERT INTO artist_tag (artist, count, last_updated, tag) VALUES
	(177, 1, '2014-12-14 16:05:15.44311-06', 111),
	(177, 1, '2014-12-14 16:05:15.44311-06', 150),
	(177, 1, '2014-12-14 16:05:15.44311-06', 235),
	(177, 1, '2014-12-14 16:05:15.44311-06', 267),
	(177, 1, '2014-12-14 16:05:15.44311-06', 1175),
	(177, 1, '2014-12-14 16:05:15.44311-06', 1176),
	(177, 1, '2014-12-14 16:05:15.44311-06', 1225),
	(177, 1, '2014-12-14 16:05:15.44311-06', 4667),
	(952603, 1, '2013-04-15 02:09:36.923601-05', 267);
INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
	(222, NULL, NULL, NULL, 2000, '', 0, NULL, NULL, NULL, 2005, '1', NULL, '54cb2d97-0f2e-49a9-afba-1f43ec76d519', 120186, '2014-12-27 13:01:31.520779-06', 'Tha Eastsidaz', 'Eastsidaz, Tha', 2),
	(222, 7324, NULL, NULL, 1991, 'american hip hop group', 0, NULL, NULL, NULL, 2011, '1', NULL, '1c294605-8a44-4a49-9f6e-be26f5fa4f38', 175345, '2013-08-06 13:00:32.601646-05', '213', '213', 2);
INSERT INTO artist_alias (artist, begin_date_day, begin_date_month, begin_date_year, edits_pending, end_date_day, end_date_month, end_date_year, ended, id, last_updated, locale, name, primary_for_locale, sort_name, type) VALUES
	(120186, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 10390, '2012-05-15 13:57:13.252186-05', NULL, 'The Eastsidaz', '0', 'The Eastsidaz', NULL),
	(120186, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 10397, '2012-05-15 13:57:13.252186-05', NULL, 'Eastsidaz', '0', 'Eastsidaz', NULL),
	(120186, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 86836, '2012-05-15 13:57:13.252186-05', NULL, 'East Sidaz', '0', 'East Sidaz', NULL),
	(120186, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 21715, '2012-05-15 13:57:13.252186-05', NULL, 'Snoop Dogg Presents Tha Eastsidaz', '0', 'Snoop Dogg Presents Tha Eastsidaz', NULL),
	(120186, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 16725, '2012-05-15 13:57:13.252186-05', NULL, 'Snoop Dogg Pres. Tha Eastsidaz', '0', 'Snoop Dogg Pres. Tha Eastsidaz', NULL);
INSERT INTO tag (id, name, ref_count) VALUES
	(33205, 'rap hip hop west coast', 1);
INSERT INTO artist_tag (artist, count, last_updated, tag) VALUES
	(175345, 1, '2012-07-22 16:52:57.065532-05', 235),
	(175345, 1, '2011-05-16 09:57:06.530063-05', 33205);
INSERT INTO link (attribute_count, begin_date_day, begin_date_month, begin_date_year, created, end_date_day, end_date_month, end_date_year, ended, id, link_type) VALUES
	(0, NULL, NULL, NULL, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 6337, 103);
INSERT INTO l_artist_artist (edits_pending, entity0, entity0_credit, entity1, entity1_credit, id, last_updated, link, link_order) VALUES
	(0, 177, '', 175345, '', 87535, '2012-08-13 03:04:03.954868-05', 6337, 0),
	(0, 177, '', 120186, '', 147355, '2012-08-13 03:04:03.954868-05', 6337, 0);
INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
	(222, 7324, 20, 10, 1971, '', 0, NULL, NULL, NULL, NULL, '0', 1, '965f5705-6eb1-49a1-b312-cd3d65bcc7c9', 249253, '2014-03-18 01:34:05.101474-05', 'Calvin Broadus', 'Broadus, Calvin', 1);
INSERT INTO artist_alias (artist, begin_date_day, begin_date_month, begin_date_year, edits_pending, end_date_day, end_date_month, end_date_year, ended, id, last_updated, locale, name, primary_for_locale, sort_name, type) VALUES
	(249253, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 127394, '2012-12-07 10:39:39.499992-06', NULL, 'Cordozar Broadus', '0', 'Broadus, Cordozar', NULL),
	(249253, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 127395, '2012-12-07 10:40:28.18492-06', NULL, 'Calvin Cordozar Broadus, Jr.', '0', 'Broadus, Calvin Cordozar, Jr.', 2),
	(249253, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 137897, '2013-09-22 08:00:35.324187-05', 'en', 'C. Broadus', '0', 'Broadus, C.', NULL),
	(249253, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 74640, '2012-05-15 13:57:13.252186-05', NULL, 'Cordozar Calvin Broadus, Jr.', '0', 'Cordozar Calvin Broadus, Jr.', NULL);
INSERT INTO link (attribute_count, begin_date_day, begin_date_month, begin_date_year, created, end_date_day, end_date_month, end_date_year, ended, id, link_type) VALUES
	(0, NULL, NULL, NULL, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 6340, 108),
	(0, NULL, 8, 2012, '2012-08-02 15:52:26.273638-05', NULL, NULL, NULL, '0', 53805, 108);
INSERT INTO l_artist_artist (edits_pending, entity0, entity0_credit, entity1, entity1_credit, id, last_updated, link, link_order) VALUES
	(0, 249253, '', 177, '', 119775, '2012-12-12 09:33:06.221051-06', 6340, 0),
	(0, 249253, '', 952603, '', 200073, '2012-12-12 09:33:33.03652-06', 53805, 0);
INSERT INTO url (edits_pending, gid, id, last_updated, url) VALUES
	(0, 'fa4a8fc6-3735-40b2-b756-d93bc7d4c56d', 2867, '2014-04-21 03:59:55.007119-05', 'http://snoopdogg.com/'),
	(0, 'faa5dfde-719f-4db3-9a0d-071e612e80a8', 2869, '2012-08-10 05:11:50.345284-05', 'http://en.wikipedia.org/wiki/Snoop_Dogg'),
	(0, '834ba9c0-2330-4948-9e85-763afdb22137', 4290, '2011-05-16 11:31:52-05', 'http://musicmoz.org/Bands_and_Artists/S/Snoop_Dogg/'),
	(0, 'e93fe5ab-9783-47bc-a8d6-a2c235debd59', 28335, '2011-05-16 11:31:52-05', 'https://www.imdb.com/name/nm0004879/'),
	(0, '71f152f2-8cca-482a-bc25-8045461f7e1a', 135938, '2014-01-21 03:14:41.284747-06', 'http://www.discogs.com/artist/132084'),
	(0, 'bf09ffbc-b764-4dba-9b29-9c8c646018a3', 135939, '2013-08-14 01:34:12.721194-05', 'https://myspace.com/snoopdogg'),
	(0, '4a4cbf56-e419-4ce8-a691-55053ee0ce2b', 585101, '2011-05-16 11:31:52-05', 'https://www.bbc.co.uk/music/artists/f90e8b26-9e52-4669-a5c9-e28529c47894'),
	(0, 'cb65a4c7-37db-4fe9-963d-e397fc5c1bf6', 685553, '2013-08-04 04:47:07.675952-05', 'https://twitter.com/snoopdogg'),
	(0, '09c3d062-55c2-4bb7-8ce7-e920ea117c6f', 950156, '2013-03-11 05:41:19.165627-05', 'https://www.facebook.com/snoopdogg'),
	(0, '6d31d1e0-9aab-4829-a2ee-0c937bc87feb', 1025694, '2012-11-01 19:27:36.426054-05', 'https://www.allmusic.com/artist/mn0000029086'),
	(0, '076ca1e1-fddf-4b99-bb64-1352d07db17f', 1354400, '2012-05-28 09:02:17.284797-05', 'https://www.last.fm/music/Snoop+Dogg'),
	(0, 'e36778ad-e619-4d7d-9b0f-e91edad181af', 1354407, '2012-05-28 09:03:11.967426-05', 'http://www.youtube.com/user/westfesttv'),
	(0, '494ef911-ee1f-4ddb-9215-4e4a165171d8', 1364164, '2013-08-17 15:45:12.541413-05', 'https://soundcloud.com/snoopdogg'),
	(0, '47cd6b41-8b4f-4304-a5b5-5a78f1e81179', 1453869, '2014-03-31 02:14:27.347801-05', 'http://www.discogs.com/artist/2859872'),
	(0, '2848f6d8-95b9-4b85-bc76-2f6dd445cc66', 1453888, '2013-08-17 15:45:19.534687-05', 'https://soundcloud.com/snooplion'),
	(0, 'a9e36e7b-1718-4497-8053-45fec71772ac', 1453892, '2013-02-21 05:36:45.555809-06', 'https://www.facebook.com/SnoopLion'),
	(0, '886b502e-7b0b-431d-a25a-b67038e8cbb0', 1453898, '2013-08-04 04:47:03.751679-05', 'https://twitter.com/snoop_lion'),
	(0, '0db87688-df61-4718-a92a-b5c47ea7f0fe', 1453899, '2014-04-21 04:00:01.245971-05', 'http://snooplion.com/'),
	(0, '1f5cda93-7a0d-4ec5-abce-60a73d2e68cc', 1557308, '2012-12-12 09:40:14.808532-06', 'https://www.allmusic.com/artist/mn0002979185'),
	(0, '7d5e7343-d766-412e-bfce-056cceb1cfc8', 1831349, '2013-07-21 14:40:30.130612-05', 'http://www.wikidata.org/wiki/Q6096'),
	(0, '64717cda-448f-4a2e-81b8-41e90381c169', 1873266, '2013-08-05 09:30:29.751164-05', 'http://rateyourmusic.com/artist/snoop_dogg'),
	(0, 'abee4ba9-7090-4443-bbba-87cd307a5343', 1873284, '2013-08-05 09:59:57.470073-05', 'http://www.purevolume.com/snoopdogg'),
	(0, '8a14bf87-1345-46f7-936b-06799f9937bb', 1873285, '2013-08-05 10:00:16.546762-05', 'http://www.secondhandsongs.com/artist/10661'),
	(0, 'a4a16a32-61b2-47e6-9016-7777693b3c46', 1873287, '2013-08-05 10:01:39.500085-05', 'http://viaf.org/viaf/61738579'),
	(0, '0fd8ed41-c273-4b6c-82a9-82d03bd3d2e3', 1873290, '2014-04-19 09:39:19.957765-05', 'https://plus.google.com/+SnoopDogg'),
	(0, 'e19286db-1f20-422a-a572-ebd7e85b742d', 2336510, '2014-01-04 06:20:17.017588-06', 'https://commons.wikimedia.org/wiki/File:Snoop_Dogg_2012.jpg'),
	(0, 'f465e8d7-f093-436c-b6ad-4051898054f2', 2370413, '2014-02-04 07:57:14.720696-06', 'http://instagram.com/snoopdogg'),
	(0, 'bf690e57-760e-4fb6-8570-bbd1d6effeac', 2414508, '2014-03-10 03:27:43.000131-05', 'http://muzikum.eu/en/122-5459/snoop-dogg/lyrics.html'),
	(0, '2fc2660d-18f2-4066-add1-e62229911c8d', 2420850, '2014-03-15 06:40:04.258583-05', 'http://www.youtube.com/user/SnoopDoggVEVO'),
	(0, '7ec6cf96-c427-4c7d-b64e-71617c9e8a32', 2425245, '2014-03-18 01:32:48.490743-05', 'https://commons.wikimedia.org/wiki/File:Summerjam_20130705_Snoop_Lion_DSC_0275_by_Emha.jpg'),
	(0, 'f79d68c6-392c-4c8b-a043-89bbf9c9f453', 2445653, '2014-03-28 05:30:27.225537-05', 'http://muzikum.eu/en/122-11979/snoop-lion/lyrics.html');
INSERT INTO link (attribute_count, begin_date_day, begin_date_month, begin_date_year, created, end_date_day, end_date_month, end_date_year, ended, id, link_type) VALUES
	(0, NULL, NULL, NULL, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 26038, 180),
	(0, NULL, NULL, NULL, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 26039, 189),
	(0, NULL, NULL, NULL, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 26040, 178),
	(0, NULL, NULL, NULL, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 26041, 179),
	(0, NULL, NULL, 2006, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 26042, 183),
	(0, NULL, NULL, NULL, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 26044, 173),
	(0, NULL, NULL, NULL, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 26046, 190),
	(0, NULL, NULL, NULL, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 26055, 193),
	(0, NULL, NULL, NULL, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 26056, 192),
	(0, NULL, NULL, NULL, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 26060, 174),
	(0, NULL, NULL, NULL, '2011-05-16 10:03:23.368437-05', NULL, NULL, NULL, '0', 26062, 197),
	(0, NULL, NULL, NULL, '2011-07-28 16:05:31.894988-05', NULL, NULL, NULL, '0', 28613, 283),
	(0, NULL, NULL, NULL, '2011-10-06 21:17:24.134728-05', NULL, NULL, NULL, '0', 30134, 291),
	(0, NULL, NULL, NULL, '2012-05-28 14:09:02.61578-05', NULL, NULL, NULL, '0', 49052, 188),
	(0, NULL, NULL, NULL, '2012-12-09 10:27:34.907312-06', NULL, NULL, NULL, '0', 94979, 307),
	(0, NULL, NULL, NULL, '2013-01-29 19:44:45.99329-06', NULL, NULL, NULL, '0', 106477, 310),
	(0, NULL, NULL, NULL, '2013-05-09 04:31:21.507442-05', NULL, NULL, NULL, '0', 117675, 352);
INSERT INTO l_artist_url (edits_pending, entity0, entity0_credit, entity1, entity1_credit, id, last_updated, link, link_order) VALUES
	(0, 177, '', 135939, '', 103480, '2012-08-13 03:04:03.954868-05', 26039, 0),
	(0, 177, '', 135938, '', 105495, '2012-08-13 03:04:03.954868-05', 26038, 0),
	(0, 177, '', 685553, '', 185748, '2013-11-11 17:11:34.882829-06', 26056, 0),
	(0, 177, '', 28335, '', 201722, '2012-08-13 03:04:03.954868-05', 26040, 0),
	(0, 177, '', 4290, '', 227976, '2014-03-10 06:08:37.390428-05', 49052, 0),
	(0, 177, '', 2867, '', 234832, '2012-08-13 03:04:03.954868-05', 26042, 0),
	(0, 177, '', 585101, '', 253093, '2012-08-13 03:04:03.954868-05', 26046, 0),
	(0, 177, '', 950156, '', 346399, '2012-08-13 03:04:03.954868-05', 26056, 0),
	(0, 177, '', 1025694, '', 369806, '2012-08-13 03:04:03.954868-05', 28613, 0),
	(0, 177, '', 1354400, '', 465794, '2012-08-13 03:04:03.954868-05', 26056, 0),
	(0, 177, '', 1354407, '', 465800, '2012-08-13 03:04:03.954868-05', 26055, 0),
	(0, 177, '', 1364164, '', 469683, '2012-08-13 03:04:03.954868-05', 30134, 0),
	(0, 952603, '', 1453888, '', 509564, '2012-12-12 09:35:48.979562-06', 30134, 0),
	(0, 952603, '', 1453892, '', 509568, '2012-12-12 09:34:03.948265-06', 26056, 0),
	(0, 952603, '', 1453898, '', 509571, '2013-11-11 17:11:26.876428-06', 26056, 0),
	(0, 952603, '', 1453899, '', 509572, '2012-12-12 09:34:28.618818-06', 26042, 0),
	(0, 177, '', 2869, '', 509575, '2012-08-16 17:00:11.492342-05', 26041, 0),
	(0, 952603, '', 1453869, '', 557208, '2012-12-12 09:32:07.266808-06', 26038, 0),
	(0, 952603, '', 1557308, '', 557212, '2012-12-12 09:40:14.829429-06', 28613, 0),
	(0, 177, '', 1831349, '', 680448, '2013-07-24 10:35:57.19232-05', 117675, 0),
	(0, 177, '', 1873266, '', 697056, '2013-08-09 10:36:32.085836-05', 49052, 0),
	(0, 177, '', 1873284, '', 697062, '2013-08-09 10:35:45.687304-05', 26060, 0),
	(0, 177, '', 1873285, '', 697063, '2013-08-09 10:36:02.410442-05', 94979, 0),
	(0, 177, '', 1873287, '', 697064, '2013-08-09 10:37:26.685574-05', 106477, 0),
	(0, 177, '', 1873290, '', 697065, '2013-08-09 10:37:56.363521-05', 26056, 0),
	(0, 177, '', 2336510, '', 812878, '2014-01-11 07:00:40.084609-06', 26044, 0),
	(0, 177, '', 2370413, '', 828127, '2014-02-11 08:00:25.242977-06', 26056, 0),
	(0, 177, '', 2414508, '', 845619, '2014-03-17 04:00:15.114876-05', 26062, 0),
	(0, 177, '', 2420850, '', 848619, '2014-03-22 07:00:29.084813-05', 26055, 0),
	(0, 952603, '', 2869, '', 850664, '2014-03-25 02:00:13.364039-05', 26041, 0),
	(0, 952603, '', 2425245, '', 850665, '2014-03-25 02:00:13.408438-05', 26044, 0),
	(0, 952603, '', 2445653, '', 858186, '2014-04-04 06:00:23.166986-05', 26062, 0),
	(0, 952603, '', 1831349, '', 909653, '2014-07-08 09:00:30.654734-05', 117675, 0);

-- Restore triggers.
CREATE TRIGGER deny_deprecated BEFORE UPDATE OR INSERT ON link FOR EACH ROW EXECUTE PROCEDURE deny_deprecated_links();
