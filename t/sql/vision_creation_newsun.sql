\set ON_ERROR_STOP 1

BEGIN;

INSERT INTO musicbrainz.area (id, gid, name, type, edits_pending, last_updated, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, ended, comment) VALUES
    (7282, '30bcaa92-9870-4798-be1a-4e0036755316', 'Osaka', 3, 0, '2013-11-03 21:59:16.671109+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', '');

INSERT INTO musicbrainz.artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, type, area, gender, comment, edits_pending, last_updated, ended, begin_area, end_area) VALUES
    (39282, '0798d15b-64e2-499f-9969-70167b1d8617', 'Boredoms', 'Boredoms', 1986, NULL, NULL, NULL, NULL, NULL, 2, 107, NULL, '', 0, '2015-11-20 12:30:26.835169+00', '0', 7282, NULL);

INSERT INTO musicbrainz.artist_credit (id, name, artist_count, ref_count, created, gid) VALUES
    (39282, 'Boredoms', 1, 715, '2011-05-16 16:32:11.963929+00', '0de31471-0548-340e-a14b-da214260d66d');

INSERT INTO musicbrainz.artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
    (39282, 0, 39282, 'Boredoms', '');

INSERT INTO musicbrainz.release_group (id, gid, name, artist_credit, type, comment, edits_pending, last_updated) VALUES
    (83146, '1c205925-2cfe-35c0-81de-d7ef17df9658', 'Vision Creation Newsun', 39282, 1, '', 0, '2014-04-18 01:16:56.398589+00');

INSERT INTO musicbrainz.release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode, comment, edits_pending, quality, last_updated) VALUES
    (249113, '868cc741-e3bc-31bc-9dac-756e35c8f152', 'Vision Creation Newsun', 39282, 83146, 1, 5, 486, 112, '4943674011582', '', 0, -1, '2015-11-20 11:59:16.175756+00');

INSERT INTO musicbrainz.release_country (release, country, date_year, date_month, date_day) VALUES
    (249113, 107, 1999, 10, 27);

INSERT INTO musicbrainz.label (id, gid, name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, label_code, type, area, comment, edits_pending, last_updated, ended) VALUES
    (100084, '5faa3d4f-6db9-4b93-a4c3-8efcea9b678f', 'A.K.A.records', NULL, NULL, NULL, 2003, NULL, NULL, NULL, 9, 107, 'WEA Japan label', 0, '2015-03-11 21:01:05.541156+00', '1');

INSERT INTO musicbrainz.release_label (id, release, label, catalog_number, last_updated) VALUES
    (27903, 249113, 100084, 'WPC6-10044', '2015-03-02 13:42:39.090256+00'),
    (64842, 249113, 100084, 'WPC6-10045', '2015-03-02 13:42:39.090256+00');

INSERT INTO musicbrainz.medium (id, release, position, format, name, edits_pending, last_updated, track_count) VALUES
    (249113, 249113, 1, 1, '', 0, '2011-05-16 14:57:06.530063+00', 0),
    (249114, 249113, 2, 1, '', 0, '2011-05-16 14:57:06.530063+00', 0);

INSERT INTO musicbrainz.recording (id, gid, name, artist_credit, length, comment, edits_pending, last_updated, video) VALUES
    (636551, 'f66857fb-bb59-444e-97dc-62c73e5eddae', '○', 39282, 822093, '', 0, NULL, '0'),
    (636552, '6c97b1d7-aa12-480e-8376-fa435235f164', '☆', 39282, 322933, '', 0, NULL, '0'),
    (636553, '4724088b-e032-4cba-aedc-39a1ffd1e08e', '♡', 39282, 411573, '', 0, NULL, '0'),
    (636554, '9b928fcb-6268-45ca-9fb7-37bcecd415b8', '[うずまき]', 39282, 393000, '', 0, NULL, '0'),
    (636555, '610168fc-9956-4cd1-b912-93bc633ea655', '〜', 39282, 379226, '', 0, NULL, '0'),
    (636556, '8110487a-6f0e-400f-a542-97c510a4dac2', '◎', 39282, 441240, '', 0, NULL, '0'),
    (636557, '67fe6882-7a68-471b-a459-572ad60040a6', '↑', 39282, 386026, '', 0, NULL, '0'),
    (636558, 'bde0e209-62e4-4ea4-a5b0-d3538fe56c08', 'Ω', 39282, 456266, '', 0, NULL, '0'),
    (636559, '1080b9fe-1a00-43c4-adc6-637f5cca070a', 'ずっと', 39282, 451133, '', 0, NULL, '0'),
    (1040491, '19506825-c404-43eb-9b09-86fc152c6780', '☉', 39282, 92666, '', 0, NULL, '0'),
    (1040492, '821f9cce-be76-4278-ab5c-63169792deb1', '⧖', 39282, 2138333, '', 0, '2014-05-24 23:00:30.217708+00', '0'),
    (1040493, '65d62fc9-a9d5-4470-aef1-1b5bff4b9424', '◌', 39282, 333826, '', 0, NULL, '0');

INSERT INTO musicbrainz.track (id, gid, recording, medium, position, number, name, artist_credit, length, edits_pending, last_updated, is_data_track) VALUES
    (564394, 'aaed3498-cb14-3c2b-8c08-ad03bf46ab61', 636551, 249113, 1, '1', '○', 39282, 822093, 0, '2011-05-16 16:08:20.288158+00', '0'),
    (564395, 'cce78f39-a1a0-32d5-b921-091757f28586', 636552, 249113, 2, '2', '☆', 39282, 322933, 0, '2011-05-16 16:08:20.288158+00', '0'),
    (564396, '13f2ca6e-861a-3644-9eff-b3dc73f9dc65', 636553, 249113, 3, '3', '♡', 39282, 411573, 0, '2011-05-16 16:08:20.288158+00', '0'),
    (564397, '092d9ffc-efe9-313c-8820-65f11a480e97', 636554, 249113, 4, '4', '[うずまき]', 39282, 393000, 0, '2011-05-16 16:08:20.288158+00', '0'),
    (564398, 'be5034f0-e1b1-3539-b509-3fc610d20d92', 636555, 249113, 5, '5', '〜', 39282, 379226, 0, '2011-05-16 16:08:20.288158+00', '0'),
    (564399, '66c5b778-c05f-359f-89a4-463b9bc1d80a', 636556, 249113, 6, '6', '◎', 39282, 441240, 0, '2011-05-16 16:08:20.288158+00', '0'),
    (564400, '467012bd-1370-316a-8f18-3195e6a20639', 636557, 249113, 7, '7', '↑', 39282, 386026, 0, '2011-05-16 16:08:20.288158+00', '0'),
    (564401, 'c48841cd-4a64-3a97-b7a3-e5bdfa40f951', 636558, 249113, 8, '8', 'Ω', 39282, 456266, 0, '2011-05-16 16:08:20.288158+00', '0'),
    (564402, '53e0e37b-8074-3b2a-830c-35f15c4e390c', 636559, 249113, 9, '9', 'ずっと', 39282, 451133, 0, '2011-05-16 16:08:20.288158+00', '0'),
    (892996, '2e8e2c89-d2ac-3e78-b8b9-b09f3fcf8c98', 1040491, 249114, 1, '1', '☉', 39282, 92666, 0, '2014-05-24 23:00:30.280108+00', '0'),
    (892997, '1f617cdf-a08c-393c-8b64-12a6ac54278b', 1040492, 249114, 2, '2', '⧖', 39282, 2138333, 0, '2014-05-24 23:00:30.280108+00', '0'),
    (892998, 'a9c0ac36-f77c-33f5-a8be-83eeb5a0df28', 1040493, 249114, 3, '3', '◌', 39282, 333826, 0, '2014-05-24 23:00:30.280108+00', '0');

COMMIT;
