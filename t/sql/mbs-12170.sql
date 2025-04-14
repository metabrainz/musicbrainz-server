-- Automatically generated, do not edit.
-- release 2b6c3d35-c8ad-44ba-8ea0-35b2cc27e95a

SET client_min_messages TO 'warning';

INSERT INTO musicbrainz.area (id, gid, name, type, edits_pending, last_updated, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, ended, comment) VALUES
	(1, 'aa95182f-df0a-3ad6-8bfb-4b63482cd276', 'Afghanistan', 1, 0, '2013-05-27 13:39:07.101747+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(2, '1c69b790-b46b-3e92-b6b4-93b4364badbc', 'Albania', 1, 0, '2013-05-27 13:35:38.624841+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(5, 'e01da61e-99a8-3c76-a27d-774c3f4982f0', 'Andorra', 1, 0, '2013-05-27 13:24:52.16131+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(6, '2afd5d6a-5fee-3836-8783-44d0ec9ac115', 'Angola', 1, 0, '2013-05-27 13:47:19.728195+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(9, '2a8cc14f-8d47-389b-b54d-e94312b23d27', 'Antigua and Barbuda', 1, 0, '2013-05-27 13:33:01.557289+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(10, '0df04709-c7d8-3b55-a6ea-f3e5069a947b', 'Argentina', 1, 0, '2013-05-27 14:05:48.558955+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(38, '71bbafaa-e825-3e15-8ca9-017dcad1748b', 'Canada', 1, 0, '2013-05-27 13:15:52.179105+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(222, '489ce91b-6658-3307-9877-795b68554c98', 'United States', 1, 0, '2013-06-15 18:06:39.59323+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(266, 'ae0110b6-13d4-4998-9116-5b926287aa23', 'California', 2, 0, '2013-06-05 07:15:15.329304+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(316, '645a2090-c498-48ce-a58e-11379aaac827', 'Newfoundland and Labrador', 2, 0, '2013-05-17 21:28:58.517355+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(795, '98d7df3b-6d45-4b65-ba34-aa0ea7696384', 'Escaldes-Engordany', 2, 0, '2013-11-26 08:47:39.201049+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(1160, '049bc295-0d27-46dd-8adf-740cd887e4cb', 'Saint John', 2, 0, '2013-11-02 07:31:23.157493+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(1718, '877aea20-0d89-4209-94c2-2850f421d566', 'Tiranë', 2, 0, '2013-11-02 17:37:32.544878+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(2870, '7ecb4d6e-638e-46b7-a0f9-9d979a3a5713', 'Kābul', 2, 0, '2013-11-26 16:42:11.822409+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(3128, '2aefd420-2047-418a-9f1b-51d65de443a6', 'Zaire', 2, 0, '2013-11-27 21:27:03.231677+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(5202, '538e3b99-6e61-4fd0-b2ab-e3bbd507b18a', 'Tirana', 3, 0, '2013-11-02 17:37:09.621578+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(7703, '1f40c6e1-47ba-4e35-996f-fe6ee5840e62', 'Los Angeles', 3, 0, '2014-12-11 12:34:38.893537+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(7719, '422967c2-1619-4ab4-9182-5cd8926fc7ab', 'Kabul', 3, 0, '2013-11-26 14:10:01.024524+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(13241, 'eac95d36-21f5-410f-80ed-ade6bc32267e', 'St. John''s', 3, 0, '2013-11-02 17:00:44.113833+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(30014, '2d74c2c7-3610-4182-82ad-f0ff2022fd10', 'Appleton', 3, 0, '2013-11-11 17:35:43.287919+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(79467, '9c842eb9-f268-4cf2-afa1-527317e6f308', 'Tirana', 2, 0, '2013-11-16 16:27:39.549609+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(104685, '720f8272-6ba3-48f7-b78e-14cd2641c2cf', 'Los Angeles County', 7, 0, '2014-12-17 12:44:15.174704+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(115564, '44a76f34-afec-4171-a0a0-180cf1f5dfee', 'Tarzana', 5, 0, '2015-12-02 17:22:41.349451+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', '');
INSERT INTO musicbrainz.iso_3166_1 (area, code) VALUES
	(1, 'AF'),
	(2, 'AL'),
	(5, 'AD'),
	(6, 'AO'),
	(9, 'AG'),
	(10, 'AR'),
	(38, 'CA'),
	(222, 'US');
INSERT INTO musicbrainz.iso_3166_2 (area, code) VALUES
	(795, 'AD-08'),
	(3128, 'AO-ZAI');
INSERT INTO musicbrainz.artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, type, area, gender, comment, edits_pending, last_updated, ended, begin_area, end_area) VALUES
	(736297, '6b5236be-0037-4627-af62-e396b1ca906f', 'Los Hermanos Abalos', 'Hermanos Abalos, Los', 1939, NULL, NULL, NULL, NULL, NULL, 2, 10, NULL, '', 0, '2017-06-12 09:49:04.692743+00', '0', 10, NULL),
	(1419725, '6f963d88-20e2-44b8-b0eb-a952a68fcdd9', 'Aaron Collis', 'Collis, Aaron', NULL, NULL, NULL, NULL, NULL, NULL, 1, 13241, 1, '', 0, '2016-10-10 04:02:36.37008+00', '0', 30014, NULL),
	(1563679, '831482b2-c956-419d-bf6d-9e558d005902', 'Yumba', 'Yumba', NULL, NULL, NULL, NULL, NULL, NULL, 1, 3128, NULL, 'Guitarist from Zaire', 0, '2017-09-27 22:13:51.199545+00', '0', NULL, NULL),
	(1570999, 'bc65c311-9886-41ab-bcc2-d8cf11fd9ab6', 'N.Fushigi', 'N.Fushigi', NULL, NULL, NULL, NULL, NULL, NULL, 1, 795, NULL, '', 0, '2017-10-17 01:04:32.014486+00', '0', 795, NULL),
	(1904122, '607f3b8d-d5cf-4705-98bf-32b3fac80f2c', 'Jalil Zaland', 'Zaland, Jalil', 1935, 1, 1, 2009, 4, 30, 1, 7719, 1, 'Artist from Kabul', 0, '2020-08-26 12:00:31.88669+00', '1', 7719, 115564),
	(1930528, '751196b3-5599-46be-8c44-ac44fa8158f2', 'Sigi Bastri', 'Bastri, Sigi', NULL, NULL, NULL, NULL, NULL, NULL, 1, 5202, 2, '', 0, '2020-02-09 16:19:21.070781+00', '0', 5202, NULL);
INSERT INTO musicbrainz.artist_credit (id, name, artist_count, ref_count, created, edits_pending, gid) VALUES
	(2090169, 'N.Fushigi', 1, 119, '2017-10-16 09:40:37.790841+00', 0, 'b5339e31-e720-38c5-ae38-ad38f41ddbc1'),
	(2620199, 'Sigi Bastri', 1, 3, '2020-02-09 17:06:10.784351+00', 0, 'b142b4b9-99fd-3f33-9619-cd1c39059566'),
	(3632617, 'Jalil Zaland', 1, 1, '2025-03-12 05:43:13.979331+00', 0, 'b1d3d903-f76f-47ea-9e20-893c7f5520eb'),
	(3632618, 'Yumba', 1, 1, '2025-03-12 05:43:37.632726+00', 0, '96c2d4f2-bf4b-400c-9b27-8ff1e2a26509'),
	(3632619, 'Aaron Collis', 1, 1, '2025-03-12 05:43:46.482278+00', 0, '0d12dd40-533e-410f-9a53-5eb111555262');
INSERT INTO musicbrainz.artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
	(2090169, 0, 1570999, 'N.Fushigi', ''),
	(2620199, 0, 1930528, 'Sigi Bastri', ''),
	(3632617, 0, 1904122, 'Jalil Zaland', ''),
	(3632618, 0, 1563679, 'Yumba', ''),
	(3632619, 0, 1419725, 'Aaron Collis', '');
INSERT INTO musicbrainz.release_group (id, gid, name, artist_credit, type, comment, edits_pending, last_updated) VALUES
	(3329712, '6316b4db-0cdb-448d-87b5-46f31ef9fce3', 'Artist Country Test', 2090169, NULL, '', 0, '2025-03-12 05:41:35.594109+00');
INSERT INTO musicbrainz.release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode, comment, edits_pending, quality, last_updated) VALUES
	(3909966, '2b6c3d35-c8ad-44ba-8ea0-35b2cc27e95a', 'Artist Country Test', 3632617, 3329712, NULL, NULL, NULL, NULL, NULL, '', 0, -1, '2025-03-12 05:43:13.979331+00');
INSERT INTO musicbrainz.medium (id, release, position, format, name, edits_pending, last_updated, track_count) VALUES
	(4258279, 3909966, 1, 1, '', 0, '2025-03-12 05:41:22.618893+00', 1);
INSERT INTO musicbrainz.recording (id, gid, name, artist_credit, length, comment, edits_pending, last_updated, video) VALUES
	(35149182, '831c6058-f19a-4a7a-9723-cd02daf8f3a5', 'A', 3632618, NULL, '', 0, '2025-03-12 05:43:37.632726+00', '0');
INSERT INTO musicbrainz.track (id, gid, recording, medium, position, number, name, artist_credit, length, edits_pending, last_updated, is_data_track) VALUES
	(42683776, '5dd38166-bcbc-44b5-9617-4dc669cf76dd', 35149182, 4258279, 1, '1', 'A', 2620199, NULL, 0, '2025-03-12 05:43:14.982087+00', '0');
INSERT INTO musicbrainz.work (id, gid, name, type, comment, edits_pending, last_updated) VALUES
	(14136046, 'b9121cf5-0641-453b-bb99-a88f0bc18751', 'A', NULL, '', 0, '2025-03-12 05:44:48.985737+00');
INSERT INTO musicbrainz.link (id, link_type, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, attribute_count, created, ended) VALUES
	(12758, 156, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2011-05-16 15:03:23.368437+00', '0'),
	(12888, 167, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2011-05-16 15:03:23.368437+00', '0'),
	(27124, 278, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2011-05-16 15:03:23.368437+00', '0'),
	(118734, 356, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2013-05-17 20:05:50.534145+00', '0');
INSERT INTO musicbrainz.l_area_area (id, link, entity0, entity1, edits_pending, last_updated, link_order, entity0_credit, entity1_credit) VALUES
	(6, 118734, 222, 266, 0, '2013-05-17 20:08:33.220791+00', 0, '', ''),
	(57, 118734, 38, 316, 0, '2013-05-17 21:29:07.58816+00', 0, '', ''),
	(555, 118734, 5, 795, 0, '2013-05-19 16:44:25.325639+00', 0, '', ''),
	(920, 118734, 9, 1160, 0, '2013-05-19 20:07:51.794715+00', 0, '', ''),
	(1478, 118734, 2, 1718, 0, '2013-05-20 11:16:54.434236+00', 0, '', ''),
	(2636, 118734, 1, 2870, 0, '2013-05-20 21:33:23.58959+00', 0, '', ''),
	(2894, 118734, 6, 3128, 0, '2013-05-20 22:47:44.077297+00', 0, '', ''),
	(4968, 118734, 79467, 5202, 0, '2013-11-16 16:28:48.754748+00', 0, '', ''),
	(7469, 118734, 104685, 7703, 0, '2014-12-17 13:36:51.897737+00', 0, '', ''),
	(7485, 118734, 2870, 7719, 0, '2013-05-29 00:13:36.962626+00', 0, '', ''),
	(13003, 118734, 1160, 13241, 0, '2013-07-18 06:29:57.799072+00', 0, '', ''),
	(29772, 118734, 316, 30014, 0, '2013-10-15 09:41:17.952656+00', 0, '', ''),
	(79224, 118734, 1718, 79467, 0, '2013-11-16 16:28:37.204946+00', 0, '', ''),
	(104500, 118734, 266, 104685, 0, '2014-12-17 12:44:15.174704+00', 0, '', ''),
	(115422, 118734, 7703, 115564, 0, '2015-12-02 17:22:41.349451+00', 0, '', '');
INSERT INTO musicbrainz.l_artist_recording (id, link, entity0, entity1, edits_pending, last_updated, link_order, entity0_credit, entity1_credit) VALUES
	(14833918, 12758, 736297, 35149182, 0, '2025-03-12 05:44:50.291085+00', 0, '', '');
INSERT INTO musicbrainz.l_recording_work (id, link, entity0, entity1, edits_pending, last_updated, link_order, entity0_credit, entity1_credit) VALUES
	(6344046, 27124, 35149182, 14136046, 0, '2025-03-12 05:44:50.291085+00', 0, '', '');
INSERT INTO musicbrainz.l_artist_work (id, link, entity0, entity1, edits_pending, last_updated, link_order, entity0_credit, entity1_credit) VALUES
	(3250706, 12888, 736297, 14136046, 0, '2025-03-12 05:44:50.291085+00', 0, '', '');
