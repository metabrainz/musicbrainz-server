-- Automatically generated, do not edit.

SET client_min_messages TO 'warning';

-- Temporarily drop triggers.
DROP TRIGGER deny_deprecated ON link;

INSERT INTO area (begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_date_day, end_date_month, end_date_year, ended, gid, id, last_updated, name, type) VALUES
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', 'caac77d1-a5c8-3e6e-8e27-90b44dcc1446', 14, '2013-05-27 12:35:40.729344+00', 'Austria', 1),
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', 'afff1a94-a98b-4322-8874-3148139ab6da', 653, '2013-11-27 19:46:51.125756+00', 'Wien', 3),
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', 'f0590317-8b42-4498-a2e4-34cc5562fcf8', 5249, '2013-11-04 15:56:50.409853+00', 'Salzburg', 3);
INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
	(14, 5249, 27, 1, 1756, 'classical composer', 0, 653, 5, 12, 1791, '1', 1, 'b972f589-fb0e-474e-b64a-803b0364fa75', 11285, '2015-04-05 17:06:48.425647+00', 'Wolfgang Amadeus Mozart', 'Mozart, Wolfgang Amadeus', 1);
INSERT INTO artist_alias (artist, begin_date_day, begin_date_month, begin_date_year, edits_pending, end_date_day, end_date_month, end_date_year, ended, id, last_updated, locale, name, primary_for_locale, sort_name, type) VALUES
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 132538, '2013-04-15 22:03:26.978518+00', NULL, 'Wolfgang Anadeus Mozart', '0', 'Wolfgang Anadeus Mozart', NULL),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 101965, '2013-04-01 13:25:23.107879+00', 'lv', 'Volfgangs Amadejs Mocarts', '1', 'Mocarts, Volfgangs Amadejs', 1),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 9726, '2013-04-01 13:22:30.638199+00', NULL, 'W.A. Mozart', '0', 'W.A. Mozart', 3),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 15223, '2013-04-01 13:23:55.139438+00', NULL, 'W A Mozart', '0', 'W A Mozart', 3),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 11534, '2013-04-01 13:27:41.528227+00', NULL, 'Wolfgang Amedeus Mozart', '0', 'Wolfgang Amedeus Mozart', 3),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 132084, '2013-04-01 13:27:51.017219+00', 'de', 'Wolfgang Amadeus Mozart', '1', 'Mozart, Wolfgang Amadeus', 1),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 15536, '2013-04-01 13:27:42.605683+00', NULL, 'Wolfgang Amadeaus Mozart', '0', 'Wolfgang Amadeaus Mozart', 3),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 132085, '2013-04-01 13:27:56.777121+00', 'en', 'Wolfgang Amadeus Mozart', '1', 'Mozart, Wolfgang Amadeus', 1),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 138934, '2013-10-12 18:01:32.387222+00', NULL, 'Wolfang Amadeus Mozart', '0', 'Mozart, Wolfgang Amadeus', NULL),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 12902, '2013-04-01 13:27:27.48128+00', NULL, 'Wolfang A. Mozart', '0', 'Wolfang A. Mozart', 3),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 1483, '2013-04-03 03:18:56.457191+00', NULL, 'Mozart', '0', 'Mozart', NULL),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 9233, '2013-04-01 13:27:43.208855+00', NULL, 'Wolfgan Amadeus Mozart', '0', 'Wolfgan Amadeus Mozart', 3),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 38423, '2013-04-01 13:24:53.109094+00', 'ru', 'Вольфганг Амадей Моцарт', '1', 'Моцарт, Вольфганг Амадей', 1),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 9935, '2013-04-01 13:22:33.560714+00', NULL, 'W. A. Mozart', '0', 'W. A. Mozart', 3),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 26616, '2012-05-15 18:57:13.252186+00', NULL, 'ヴォルフガンク・アマデウス・モーツァルト', '0', 'ヴォルフガンク・アマデウス・モーツァルト', NULL),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 12172, '2013-04-01 13:27:42.671847+00', NULL, 'Wolfgang A. Mozart', '0', 'Wolfgang A. Mozart', 3),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 71325, '2013-04-01 13:22:25.531803+00', NULL, 'WA Mozart', '0', 'WA Mozart', 3),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 8283, '2013-04-01 13:27:22.845207+00', NULL, 'Wolfgang Armadeus Mozart', '0', 'Wolfgang Armadeus Mozart', 3),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 24496, '2013-04-01 13:22:16.637794+00', NULL, 'Mosart', '0', 'Mosart', 3),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 14302, '2012-05-15 18:57:13.252186+00', NULL, 'モーツァルト', '0', 'モーツァルト', NULL),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 11535, '2013-04-01 13:27:41.611527+00', NULL, 'Wolfgang Amadues Mozart', '0', 'Wolfgang Amadues Mozart', 3),
	(11285, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 64474, '2014-08-07 17:00:14.376025+00', 'ko', '볼프강 아마데우스 모짜르트', '0', '모짜르트', 1);
INSERT INTO tag (id, name, ref_count) VALUES
	(15, 'classical', 10467),
	(69, 'german', 1123),
	(480, 'opera', 256),
	(638, 'austrian', 103),
	(670, 'composer', 366),
	(1600, 'european', 411),
	(2215, 'series-mozart-complete works-philips', 161),
	(3775, '1991', 97),
	(4170, 'complete mozart edition', 7),
	(24492, 'requiem', 1),
	(38686, 'complete', 0),
	(42091, 'classical period', 0),
	(56811, 'late symphonies', 0),
	(59216, 'volume 15', 0),
	(63209, 'gould', 0),
	(63294, 'austrian composer', 0);
INSERT INTO artist_tag (artist, count, last_updated, tag) VALUES
	(11285, 7, '2015-09-14 15:56:41.786036+00', 15),
	(11285, 2, '2015-06-22 19:24:34.623089+00', 69),
	(11285, 2, '2013-10-12 18:01:32.387222+00', 480),
	(11285, 6, '2015-09-14 15:56:44.126224+00', 638),
	(11285, 4, '2015-09-14 15:56:44.65419+00', 670),
	(11285, 3, '2013-10-12 18:01:32.387222+00', 1600),
	(11285, 0, '2015-06-22 19:24:47.838411+00', 2215),
	(11285, 0, '2015-06-22 19:24:37.685419+00', 3775),
	(11285, 0, '2015-06-22 19:24:43.806428+00', 4170),
	(11285, 0, '2015-06-22 19:24:46.528047+00', 24492),
	(11285, 0, '2015-06-22 19:24:42.685345+00', 38686),
	(11285, 1, '2013-10-12 18:01:32.387222+00', 42091),
	(11285, 0, '2015-06-22 19:24:45.911593+00', 56811),
	(11285, 0, '2015-06-22 19:24:48.532487+00', 59216),
	(11285, 0, '2015-06-22 19:24:44.361383+00', 63209),
	(11285, 1, '2013-11-27 09:36:36.75874+00', 63294);
INSERT INTO area (begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_date_day, end_date_month, end_date_year, ended, gid, id, last_updated, name, type) VALUES
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', '39965a97-1571-47b2-a9cd-287cae265dcb', 23619, '2013-11-26 14:37:52.738807+00', 'Karlovy Vary', 3);
INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
	(14, 653, 26, 7, 1791, '', 0, 23619, 29, 7, 1844, '1', 1, 'dd7685f4-1e81-4da7-80a0-30299e94a9ab', 501205, '2014-03-05 00:26:54.258028+00', 'Franz Xaver Wolfgang Mozart', 'Mozart, Franz Xaver Wolfgang', 1),
	(NULL, NULL, 21, 9, 1784, '', 0, NULL, 31, 10, 1858, '1', NULL, '0ae85ff1-6ae4-4339-8764-309519bb7ebe', 501208, '2012-05-15 19:04:49.109476+00', 'Karl Thomas Mozart', 'Mozart, Karl Thomas', 1);
INSERT INTO artist_tag (artist, count, last_updated, tag) VALUES
	(501205, 1, '2014-03-05 00:25:17.577034+00', 670),
	(501205, 1, '2014-03-05 00:25:17.577034+00', 63294),
	(501205, 1, '2015-06-23 00:28:00.708999+00', 15);
INSERT INTO link (attribute_count, begin_date_day, begin_date_month, begin_date_year, created, end_date_day, end_date_month, end_date_year, ended, id, link_type) VALUES
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 6358, 109);
INSERT INTO l_artist_artist (edits_pending, entity0, entity0_credit, entity1, entity1_credit, id, last_updated, link, link_order) VALUES
	(0, 11285, '', 501208, '', 137397, '2013-10-12 18:01:32.387222+00', 6358, 0),
	(0, 11285, '', 501205, '', 137540, '2013-10-12 18:01:32.387222+00', 6358, 0);
INSERT INTO area (begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_date_day, end_date_month, end_date_year, ended, gid, id, last_updated, name, type) VALUES
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', '85752fda-13c4-31a3-bee5-0e5cb1f51dad', 81, '2013-05-27 12:44:37.529747+00', 'Germany', 1),
	(NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', '72cb4849-5677-47c2-8c5f-415c9074f5f3', 9702, '2013-11-26 04:37:58.090454+00', 'Augsburg', 3);
INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
	(81, 9702, 14, 11, 1719, '', 0, 5249, 28, 5, 1787, '1', 1, '45993ba5-2083-4011-8d76-9497067bd092', 91209, '2013-11-23 19:37:47.154793+00', 'Leopold Mozart', 'Mozart, Leopold', 1);
INSERT INTO artist_alias (artist, begin_date_day, begin_date_month, begin_date_year, edits_pending, end_date_day, end_date_month, end_date_year, ended, id, last_updated, locale, name, primary_for_locale, sort_name, type) VALUES
	(91209, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 69798, '2012-05-15 18:57:13.252186+00', NULL, 'L.モーツァルト', '0', 'L.モーツァルト', NULL),
	(91209, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 20623, '2012-05-15 18:57:13.252186+00', NULL, 'L. Mozart', '0', 'L. Mozart', NULL),
	(91209, NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 22293, '2012-05-15 18:57:13.252186+00', NULL, 'Johann Georg Leopold Mozart', '0', 'Johann Georg Leopold Mozart', NULL);
INSERT INTO tag (id, name, ref_count) VALUES
	(117, 'german composer', 2),
	(359, 'production music', 15854);
INSERT INTO artist_tag (artist, count, last_updated, tag) VALUES
	(91209, 2, '2011-05-16 14:57:06.530063+00', 15),
	(91209, 2, '2011-05-16 14:57:06.530063+00', 69),
	(91209, 1, '2014-03-23 01:29:02.085678+00', 117),
	(91209, 1, '2011-05-16 14:57:06.530063+00', 359),
	(91209, 2, '2011-05-16 14:57:06.530063+00', 638),
	(91209, 1, '2014-03-23 01:29:02.085678+00', 670),
	(91209, 1, '2011-05-16 14:57:06.530063+00', 1600);
INSERT INTO l_artist_artist (edits_pending, entity0, entity0_credit, entity1, entity1_credit, id, last_updated, link, link_order) VALUES
	(0, 91209, '', 11285, '', 124738, '2013-10-12 18:01:32.387222+00', 6358, 0);
INSERT INTO series (comment, edits_pending, gid, id, last_updated, name, ordering_type, type) VALUES
	('original numbering', 0, '793b0ca8-a301-4b08-8692-25999b32d34f', 12, '2014-06-11 19:00:34.654293+00', 'Köchelverzeichnis', 1, 5),
	('', 0, 'b13f2233-9ba1-4fdb-8775-3e9bb0668805', 777, '2014-06-11 21:01:05.866626+00', 'Nannerl Notenbuch', 1, 4),
	('sixth edition, 1964, K⁶', 0, 'b2ebc151-25b5-4522-9d01-402d3ebfb2d7', 778, '2014-06-12 00:00:12.971562+00', 'Köchelverzeichnis', 1, 5),
	('third edition, 1937, K³', 0, '13016d44-1ce5-4bc7-8b01-853ce19e74dc', 1007, '2014-06-16 22:15:02.050568+00', 'Köchelverzeichnis', 1, 5),
	('second edition, 1905, K²', 0, '3e32505b-0eea-464c-a009-eae16ba88517', 1008, '2014-06-16 22:14:07.661735+00', 'Köchelverzeichnis', 1, 5);
INSERT INTO series_alias (begin_date_day, begin_date_month, begin_date_year, edits_pending, end_date_day, end_date_month, end_date_year, ended, id, last_updated, locale, name, primary_for_locale, series, sort_name, type) VALUES
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 1, '2014-05-14 18:28:59.030601+00', 'en', 'Köchel catalogue', '1', 12, 'Köchel catalogue', 1),
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 4, '2014-05-14 18:28:59.030601+00', 'de', 'Köchelverzeichnis', '1', 12, 'Köchelverzeichnis', 1),
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 12, '2014-05-14 18:42:47.404571+00', NULL, 'KV', '0', 12, 'KV', 2),
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 83, '2014-06-11 18:00:40.850685+00', NULL, 'K', '0', 12, 'K', 2),
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 86, '2014-06-11 19:00:34.654293+00', NULL, 'K¹', '0', 12, 'K¹', 2),
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 87, '2014-06-11 21:01:05.719776+00', 'en', 'Nannerl’s Music Book', '1', 777, 'Nannerl’s Music Book', 1),
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 88, '2014-06-11 21:01:05.793976+00', 'de', 'Notenbuch für Nannerl', '0', 777, 'Notenbuch für Nannerl', 1),
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 89, '2014-06-11 21:01:05.793976+00', 'de', 'Nannerl Notenbuch', '1', 777, 'Nannerl Notenbuch', 1),
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 90, '2014-06-11 21:01:05.866626+00', NULL, 'Mozart', '0', 777, 'Mozart', 2),
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 91, '2014-06-12 00:00:12.877142+00', 'en', 'Köchel catalogue', '1', 778, 'Köchel catalogue', 1),
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 92, '2014-06-12 00:00:12.903576+00', NULL, 'K.', '0', 778, 'K.', 2),
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 93, '2014-06-12 00:00:12.916777+00', NULL, 'K⁶', '0', 778, 'K⁶', 2),
	(NULL, NULL, NULL, 0, NULL, NULL, NULL, '0', 94, '2014-06-12 00:00:12.971562+00', NULL, 'KV', '0', 778, 'KV', 2);
INSERT INTO series_tag (count, last_updated, series, tag) VALUES
	(1, '2015-10-11 18:39:08.3685+00', 12, 15),
	(1, '2015-10-11 18:39:15.40333+00', 778, 15);
INSERT INTO link (attribute_count, begin_date_day, begin_date_month, begin_date_year, created, end_date_day, end_date_month, end_date_year, ended, id, link_type) VALUES
	(0, NULL, NULL, NULL, '2014-05-14 23:25:53.495592+00', NULL, NULL, NULL, '0', 167393, 750);
INSERT INTO l_artist_series (edits_pending, entity0, entity0_credit, entity1, entity1_credit, id, last_updated, link, link_order) VALUES
	(0, 11285, '', 12, '', 3, '2014-05-14 23:31:07.950348+00', 167393, 0),
	(0, 11285, '', 777, '', 177, '2014-06-04 21:04:35.271952+00', 167393, 0),
	(0, 11285, '', 778, '', 178, '2014-06-04 22:06:56.820188+00', 167393, 0),
	(0, 11285, '', 1007, '', 215, '2014-06-16 22:10:38.544709+00', 167393, 0),
	(0, 11285, '', 1008, '', 217, '2014-06-16 22:14:07.661735+00', 167393, 0);
INSERT INTO url (edits_pending, gid, id, last_updated, url) VALUES
	(0, 'c53f888b-c808-48c8-93bb-ad3f2bd630cb', 549, '2011-05-16 16:31:52+00', 'http://en.wikipedia.org/wiki/Wolfgang_Amadeus_Mozart'),
	(0, 'a6320f0d-424b-4a49-b6ca-61e30389ad1d', 111409, '2011-05-16 16:31:52+00', 'http://musicmoz.org/Composition/Composers/M/Mozart,_Wolfgang_Amadeus/'),
	(0, 'f73e9633-858b-4d72-b570-d1eb536e96ce', 111410, '2011-05-16 16:31:52+00', 'https://www.imdb.com/name/nm0003665/'),
	(0, '68bdea58-aee0-4bc3-9aa5-4a2ac43cecb3', 307776, '2014-01-17 16:26:30.650232+00', 'http://www.discogs.com/artist/95546'),
	(0, '22e26c8e-16c4-4ee3-9286-9a3307aa6562', 581105, '2011-05-16 16:31:52+00', 'http://www.pbs.org/wnet/gperf/education/mozart.html'),
	(0, '7cde31b5-1107-4b30-a31a-56c95504564d', 584364, '2011-05-16 16:31:52+00', 'https://www.bbc.co.uk/music/artists/b972f589-fb0e-474e-b64a-803b0364fa75'),
	(0, 'af8d2f64-0a2b-4cf2-b186-7355fd15f9d8', 944664, '2012-11-03 01:40:52.561713+00', 'https://www.allmusic.com/artist/mn0000026350'),
	(0, 'fc052e4e-2247-4fa3-82bc-e7b90a47dc7f', 1598278, '2013-01-30 22:16:55.205991+00', 'http://viaf.org/viaf/32197206'),
	(0, '7c4aee9f-02bd-45e0-a473-867c56ceca1a', 1709986, '2013-05-15 21:44:14.701946+00', 'http://www.wikidata.org/wiki/Q254'),
	(0, '4dc4d521-d284-40a3-9d4a-7608abd01682', 1780932, '2013-06-19 09:59:24.209248+00', 'http://vgmdb.net/artist/174'),
	(0, '6ee379fe-41a7-486f-8454-ca0c5e5a1a57', 1780933, '2013-06-19 09:59:48.837367+00', 'http://rateyourmusic.com/artist/wolfgang_amadeus_mozart'),
	(0, 'a1a9b941-dad5-4977-93a6-51dbc966c306', 1814202, '2013-07-10 08:57:12.691618+00', 'https://www.last.fm/music/Wolfgang+Amadeus+Mozart'),
	(0, 'c4c3ea4f-44c1-4139-8467-b960fac69515', 2212776, '2013-11-19 03:00:05.396745+00', 'https://commons.wikimedia.org/wiki/File:Croce-Mozart-Detail.jpg'),
	(0, 'ebc7f6b0-3ecc-49e8-8f1e-ed458c9ce1b1', 2323468, '2013-12-22 22:40:40.987781+00', 'http://viaf.org/viaf/263782738'),
	(0, 'b76c8278-6926-4988-82cc-4ca40ba04a98', 3135602, '2015-06-07 10:09:19.374568+00', 'http://open.spotify.com/artist/4NJhFmfw43RLBLjQvxDuRS'),
	(0, '488cb07d-85a9-4f9e-bbb7-5ff499242b56', 3277660, '2015-09-14 17:07:38.976791+00', 'http://soundtrackcollector.com/composer/30/');
INSERT INTO link (attribute_count, begin_date_day, begin_date_month, begin_date_year, created, end_date_day, end_date_month, end_date_year, ended, id, link_type) VALUES
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 26038, 180),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 26040, 178),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 26041, 179),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 26044, 173),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 26046, 190),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 26049, 182),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 26068, 191),
	(0, NULL, NULL, NULL, '2011-05-16 15:03:23.368437+00', NULL, NULL, NULL, '0', 26316, 194),
	(0, NULL, NULL, NULL, '2011-07-28 21:05:31.894988+00', NULL, NULL, NULL, '0', 28613, 283),
	(0, NULL, NULL, NULL, '2012-05-28 19:09:02.61578+00', NULL, NULL, NULL, '0', 49052, 188),
	(0, NULL, NULL, NULL, '2013-01-30 01:44:45.99329+00', NULL, NULL, NULL, '0', 106477, 310),
	(0, NULL, NULL, NULL, '2013-05-09 09:31:21.507442+00', NULL, NULL, NULL, '0', 117675, 352),
	(0, NULL, NULL, NULL, '2015-02-03 11:01:37.730965+00', NULL, NULL, NULL, '0', 215573, 840);
INSERT INTO l_artist_url (edits_pending, entity0, entity0_credit, entity1, entity1_credit, id, last_updated, link, link_order) VALUES
	(0, 11285, '', 111410, '', 131453, '2013-10-12 18:01:32.387222+00', 26040, 0),
	(0, 11285, '', 111409, '', 132371, '2014-03-10 10:57:11.292531+00', 49052, 0),
	(0, 11285, '', 307776, '', 190515, '2013-10-12 18:01:32.387222+00', 26038, 0),
	(0, 11285, '', 549, '', 239185, '2013-10-12 18:01:32.387222+00', 26041, 0),
	(0, 11285, '', 584364, '', 239287, '2013-10-12 18:01:32.387222+00', 26046, 0),
	(0, 11285, '', 581105, '', 251781, '2013-10-12 18:01:32.387222+00', 26049, 0),
	(0, 11285, '', 944664, '', 344283, '2013-10-12 18:01:32.387222+00', 28613, 0),
	(0, 11285, '', 1598278, '', 576273, '2013-10-12 18:01:32.387222+00', 106477, 0),
	(0, 11285, '', 1709986, '', 633784, '2013-10-12 18:01:32.387222+00', 117675, 0),
	(0, 11285, '', 1780932, '', 660101, '2013-10-12 18:01:32.387222+00', 26068, 0),
	(0, 11285, '', 1780933, '', 660102, '2013-10-12 18:01:32.387222+00', 49052, 0),
	(0, 11285, '', 1814202, '', 674425, '2015-02-15 07:41:26.832845+00', 215573, 0),
	(0, 11285, '', 2212776, '', 777708, '2013-11-19 03:00:05.432571+00', 26044, 0),
	(0, 11285, '', 2323468, '', 808124, '2013-12-22 22:40:41.004268+00', 106477, 0),
	(0, 11285, '', 3135602, '', 1108367, '2015-06-13 23:00:41.760446+00', 26316, 0),
	(0, 11285, '', 3277660, '', 1171850, '2015-09-21 18:00:41.856512+00', 49052, 0);

-- Restore triggers.
CREATE TRIGGER deny_deprecated BEFORE UPDATE OR INSERT ON link FOR EACH ROW EXECUTE PROCEDURE deny_deprecated_links();
