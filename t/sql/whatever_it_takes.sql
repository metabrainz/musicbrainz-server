\set ON_ERROR_STOP 1

BEGIN;

INSERT INTO area (id, gid, name, type, edits_pending, last_updated, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, ended, comment) VALUES
    (5213, 'e68879f9-bd95-41ff-96ba-c082ff37cc74', 'Nashville', 3, 0, '2013-05-24 20:50:05.751282+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
    (5283, 'dbacf2e3-7e3e-4cee-8804-999b109285fa', 'Santa Monica', 3, 0, '2013-05-24 21:03:21.166742+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
    (23187, 'cd22d0ba-c79b-45b3-a8e0-617b240df5f0', 'Las Vegas', 3, 0, '2013-08-22 06:23:56.045928+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
    (38137, 'c4185c64-6396-45ce-bcad-3da7c7d4b73e', 'Wilmette', 3, 0, '2013-10-23 10:14:10.890767+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', '');

INSERT INTO artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, type, area, gender, comment, edits_pending, last_updated, ended, begin_area, end_area) VALUES
    (679159, 'd1fc999f-6184-41a6-bcb1-7c59bf74a6e1', 'K.Flay', 'K.Flay', 1985, 6, 30, NULL, NULL, NULL, 1, 222, 2, '', 0, '2017-07-13 06:00:22.322448+00', '0', 38137, NULL),
    (870909, '012151a8-0f9a-44c9-997f-ebd68b5389f9', 'Imagine Dragons', 'Imagine Dragons', 2008, NULL, NULL, NULL, NULL, NULL, 2, 222, NULL, '', 0, '2015-02-05 03:45:57.476136+00', '0', 23187, NULL);

INSERT INTO artist_credit (id, name, artist_count, ref_count, created, edits_pending, gid) VALUES
    (950778, 'Imagine Dragons', 1, 2, '2012-02-28 10:57:22.111172+00', 0, '1c681b7d-d556-3e03-81ff-2558cbc34d50'),
    (2064806, 'Imagine Dragons & K.Flay', 2, 5, '2017-09-07 14:49:11.631089+00', 0, 'a3036839-22ae-38c5-9b35-1cc39d176746');

INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
    (950778, 0, 870909, 'Imagine Dragons', ''),
    (2064806, 0, 870909, 'Imagine Dragons', ' & '),
    (2064806, 1, 679159, 'K.Flay', '');

INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending, last_updated) VALUES
    (1803671, '69ed06a7-7a05-406a-92a2-f3216d1c1561', 'Whatever It Takes', 950778, 2, '', 0, '2017-05-09 04:59:12.01423+00'),
    (1882825, '251e0b53-9b79-48b9-9e0e-e4b9795825b9', 'Whatever It Takes (Jorgen Odegard remix)', 950778, 2, '', 0, '2017-11-09 17:17:25.768881+00');

INSERT INTO release_group_secondary_type_join (release_group, secondary_type, created) VALUES
    (1882825, 7, '2017-11-09 17:17:25.768881+00');

INSERT INTO release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode, comment, edits_pending, quality, last_updated) VALUES
    (2063427, '4798b503-c1ec-49f3-820a-47bde61898b7', 'Whatever It Takes (Jorgen Odegard remix)', 950778, 1882825, 1, 7, 120, 28, NULL, '', 0, -1, '2017-11-16 18:00:16.709434+00'),
    (2095272, '61ccc0c2-9738-45ad-ad81-4d7152f33d7c', 'Whatever It Takes', 950778, 1803671, 1, 2, 120, 28, '0602567158394', '', 0, -1, '2018-05-14 17:00:23.138322+00');

INSERT INTO release_country (release, country, date_year, date_month, date_day) VALUES
    (2063427, 13, 2017, 11, 10),
    (2095272, 241, 2017, 11, 17);

INSERT INTO label (id, gid, name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, label_code, type, area, comment, edits_pending, last_updated, ended) VALUES
    (17796, 'e79e7782-841c-40d8-8abb-1e1ec028f2e8', 'EMI Blackwood Music Inc.', 1989, 7, 24, NULL, NULL, NULL, NULL, 7, 5213, '', 0, '2018-08-20 09:02:07.095647+00', '0'),
    (59382, '1391bdc7-a22c-48a4-a5fb-e7b8ef6ce143', 'Universal', NULL, NULL, NULL, NULL, NULL, NULL, 1846, NULL, NULL, 'plain logo: "Universal"', 0, '2015-03-18 03:14:22.164581+00', '0'),
    (62551, '45abf89e-d453-411c-b458-8db860a0001a', 'Songs of Universal, Inc.', 1966, NULL, NULL, NULL, NULL, NULL, NULL, 7, 5283, '', 0, '2017-12-06 06:54:44.493179+00', '0'),
    (81438, 'f3dfa985-1af3-4eb0-86d0-582d057c5d62', 'KIDinaKORNER', 2011, NULL, NULL, NULL, NULL, NULL, NULL, 9, NULL, '', 0, '2019-03-16 08:00:20.622301+00', '0'),
    (93613, '27fa2fe5-a1d0-4984-86a6-33b61f7908de', 'Imagine Dragons Publishing', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 7, 222, '', 0, '2015-12-28 05:00:18.865993+00', '0'),
    (150162, '7f32b5bb-aab3-4b44-be6a-b6a0d7516709', 'Have a Nice Jay', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, '', 0, '2018-02-27 06:39:04.234218+00', '0'),
    (150165, 'd3f602d4-d0d1-47a4-bd3e-b574ed9f0b92', 'Universal, Inc.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, '', 0, '2018-02-27 07:36:00.72512+00', '0');

INSERT INTO release_label (id, release, label, catalog_number, last_updated) VALUES
    (1585105, 2063427, 620, NULL, '2017-11-09 17:17:32.741652+00'),
    (1585104, 2063427, 81438, NULL, '2017-11-09 17:17:32.741652+00'),
    (1616636, 2095272, 620, '0602567158394', '2018-01-03 13:13:49.095972+00'),
    (1616635, 2095272, 81438, '0602567158394', '2018-01-03 13:13:49.095972+00');

INSERT INTO medium (id, release, position, format, name, edits_pending, last_updated, track_count) VALUES
    (2217508, 2063427, 1, 12, '', 0, '2017-11-09 17:17:36.779181+00', 0),
    (2254441, 2095272, 1, 1, '', 0, '2018-01-03 13:13:55.205253+00', 0);

INSERT INTO medium_index (medium, toc) VALUES
    (2217508, '(232000, 0, 0, 0, 0, 0)'),
    (2254441, '(202000, 197000, 0, 0, 0, 0)');

INSERT INTO recording (id, gid, name, artist_credit, length, comment, edits_pending, last_updated, video) VALUES
    (20906575, 'ba172571-a0c9-4e75-855a-e4365ca33833', 'Whatever It Takes', 950778, 201241, '', 0, '2017-11-19 00:00:38.828465+00', '0'),
    (21444970, '9e51cfdc-0f9d-4c4d-bde8-ded728a65a2d', 'Thunder (Official remix)', 2064806, 195720, '', 0, '2017-09-07 14:49:19.201343+00', '0'),
    (21757927, '8ebafa76-539a-4691-8126-4300f7027a39', 'Whatever It Takes (Jorgen Odegard remix)', 950778, 232000, '', 0, '2017-11-09 17:17:36.779181+00', '0');

INSERT INTO track (id, gid, recording, medium, position, number, name, artist_credit, length, edits_pending, last_updated, is_data_track) VALUES
    (24147337, '84e0236c-919d-4c0a-a1f2-69052f1c7749', 21757927, 2217508, 1, '1', 'Whatever It Takes (Jorgen Odegard remix)', 950778, 232000, 0, '2017-11-09 17:17:36.779181+00', '0'),
    (24523443, '8eda8321-6cb8-45d3-bb3e-04cf0c5435be', 20906575, 2254441, 1, '1', 'Whatever It Takes', 950778, 202000, 0, '2018-01-03 13:13:55.205253+00', '0'),
    (24523444, 'ae395f9e-cd9c-4392-af93-e4b37b936ad6', 21444970, 2254441, 2, '2', 'Thunder (Official remix)', 2064806, 197000, 0, '2018-01-03 13:13:55.205253+00', '0');

COMMIT;
