-- Automatically generated, do not edit.
-- edit 60868023

SET client_min_messages TO 'warning';

-- Temporarily drop triggers.
DROP TRIGGER deny_deprecated ON link;

INSERT INTO musicbrainz.editor (id, name, privs, email, website, bio, member_since, email_confirm_date, last_login_date, last_updated, birth_date, gender, area, password, ha1, deleted) VALUES
	(2063647, 'editor#1', 0, '', NULL, NULL, '2010-01-01 00:00:00.000000+00', '2010-01-01 00:01:00.000000+00', '2010-01-01 00:02:00.000000+00', '2010-01-01 00:02:00.000000+00', NULL, NULL, NULL, '{CLEARTEXT}mb', '7a13c7252f0d4c38e3c5e020024df011', '0');
INSERT INTO musicbrainz.edit (id, editor, type, status, autoedit, open_time, close_time, expire_time, language, quality) VALUES
	(60868023, 2063647, 311, 1, 0, '2019-04-24 05:10:31.971388+00', NULL, '2019-05-01 05:10:31.971388+00', NULL, 1);
INSERT INTO musicbrainz.edit_data (edit, data) VALUES
	(60868023, '{"new_entity": {"id": 1072194, "name": "Milestone", "events": [{"date": {"day": null, "year": 1973, "month": null}, "country_id": 99}], "labels": [], "mediums": [{"format_name": null, "track_count": 10}], "artist_credit": {"names": [{"name": "Jagjit Singh", "artist": {"id": 40043, "name": "Jagjit Singh"}, "join_phrase": ""}]}}, "old_entities": [{"id": 1608636, "name": "A Milestone", "events": [{"date": {"day": null, "year": 1980, "month": null}, "country_id": 99}], "labels": [{"label": {"id": 62793, "name": "EMI"}, "catalog_number": "ECSD 2847"}], "mediums": [{"format_name": "12\" Vinyl", "track_count": 10}], "artist_credit": {"names": [{"name": "Jagjit Singh", "artist": {"id": 40043, "name": "Jagjit Singh"}, "join_phrase": ""}]}}], "_edit_version": 3, "merge_strategy": "2", "recording_merges": []}');
INSERT INTO musicbrainz.editor (id, name, privs, email, website, bio, member_since, email_confirm_date, last_login_date, last_updated, birth_date, gender, area, password, ha1, deleted) VALUES
	(326637, 'editor#2', 0, '', NULL, NULL, '2010-01-01 00:00:00.000000+00', '2010-01-01 00:01:00.000000+00', '2010-01-01 00:02:00.000000+00', '2010-01-01 00:02:00.000000+00', NULL, NULL, NULL, '{CLEARTEXT}mb', 'b3e9a247dfd7347a0027dbff7961170d', '0'),
	(407536, 'editor#3', 0, '', NULL, NULL, '2010-01-01 00:00:00.000000+00', '2010-01-01 00:01:00.000000+00', '2010-01-01 00:02:00.000000+00', '2010-01-01 00:02:00.000000+00', NULL, NULL, NULL, '{CLEARTEXT}mb', '5f5f2a1ae5397fe1264b85d322d2ca3e', '0'),
	(487197, 'editor#4', 0, '', NULL, NULL, '2010-01-01 00:00:00.000000+00', '2010-01-01 00:01:00.000000+00', '2010-01-01 00:02:00.000000+00', '2010-01-01 00:02:00.000000+00', NULL, NULL, NULL, '{CLEARTEXT}mb', '09b0f46eaae3693c78682f0a7c35c639', '0'),
	(561161, 'editor#5', 0, '', NULL, NULL, '2010-01-01 00:00:00.000000+00', '2010-01-01 00:01:00.000000+00', '2010-01-01 00:02:00.000000+00', '2010-01-01 00:02:00.000000+00', NULL, NULL, NULL, '{CLEARTEXT}mb', 'bf006e22ee1e4d21643ca12a04f2e609', '0'),
	(798287, 'editor#6', 0, '', NULL, NULL, '2010-01-01 00:00:00.000000+00', '2010-01-01 00:01:00.000000+00', '2010-01-01 00:02:00.000000+00', '2010-01-01 00:02:00.000000+00', NULL, NULL, NULL, '{CLEARTEXT}mb', 'dcd0dd856c90a7ebd8d5f25b97563ee9', '0'),
	(1989327, 'editor#7', 0, '', NULL, NULL, '2010-01-01 00:00:00.000000+00', '2010-01-01 00:01:00.000000+00', '2010-01-01 00:02:00.000000+00', '2010-01-01 00:02:00.000000+00', NULL, NULL, NULL, '{CLEARTEXT}mb', '0b606426409cfb40dc0eb292f74fe169', '0');
INSERT INTO musicbrainz.vote (id, editor, edit, vote, vote_time, superseded) VALUES
	(15984460, 798287, 60868023, 1, '2019-06-09 23:14:00.862315+00', '0'),
	(15970508, 487197, 60868023, -1, '2019-06-07 16:34:08.946007+00', '0'),
	(15943393, 561161, 60868023, -1, '2019-06-03 08:29:45.971506+00', '0'),
	(15928315, 326637, 60868023, -1, '2019-05-31 21:17:55.77614+00', '0'),
	(15928290, 326637, 60868023, 1, '2019-05-31 21:16:28.462633+00', '1'),
	(15818097, 407536, 60868023, 1, '2019-05-10 07:19:53.206997+00', '0'),
	(15814202, 1989327, 60868023, 1, '2019-05-10 05:13:42.071024+00', '0');
INSERT INTO musicbrainz.area (id, gid, name, type, edits_pending, last_updated, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, ended, comment) VALUES
	(99, 'd31a9a15-537f-3669-ad53-25753ddd2772', 'India', 1, 0, '2013-05-27 13:20:45.066389+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', ''),
	(5092, 'e24de96f-81de-4021-8af3-1b656b6b1e42', 'Mumbai', 3, 0, '2013-11-26 20:46:56.332736+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', '');
INSERT INTO musicbrainz.iso_3166_1 (area, code) VALUES
	(99, 'IN');
INSERT INTO musicbrainz.artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, type, area, gender, comment, edits_pending, last_updated, ended, begin_area, end_area) VALUES
	(40043, 'ff7d390f-03be-40e4-9210-3e0f660966df', 'Jagjit Singh', 'Singh, Jagjit', 1941, 2, 8, 2011, 10, 10, 1, 99, 1, '', 0, '2019-02-13 18:00:20.829042+00', '1', NULL, 5092),
	(276197, '9a3dc805-9d47-4d67-b59d-47e1bfb82537', 'Chitra Singh', 'Singh, Chitra', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 2, '', 0, '2011-12-28 11:24:13.362251+00', '0', NULL, NULL);
INSERT INTO musicbrainz.artist_isni (artist, isni, edits_pending, created) VALUES
	(40043, '0000000109340667', 0, '2019-02-06 17:22:03.709705+00');
INSERT INTO musicbrainz.artist_credit (id, name, artist_count, ref_count, created, edits_pending, gid) VALUES
	(40043, 'Jagjit Singh', 1, 2162, '2011-05-16 16:32:11.963929+00', 0, '227a031b-c9bc-3220-b76f-c02a12e7daf6'),
	(276197, 'Chitra Singh', 1, 193, '2011-05-16 16:32:11.963929+00', 0, 'a4614a50-859e-36a5-abf9-96ab2caa8cea'),
	(869200, 'Jagjit Singh & Chitra Singh', 2, 605, '2011-10-12 15:49:48.884022+00', 0, 'b8facf9f-4bf7-3db5-a50f-622dfbb9b186');
INSERT INTO musicbrainz.artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
	(40043, 0, 40043, 'Jagjit Singh', ''),
	(276197, 0, 276197, 'Chitra Singh', ''),
	(869200, 0, 40043, 'Jagjit Singh', ' & '),
	(869200, 1, 276197, 'Chitra Singh', '');
INSERT INTO musicbrainz.recording (id, gid, name, artist_credit, length, comment, edits_pending, last_updated, video) VALUES
	(12721551, '8883356e-3c5e-4eb0-ad1c-89c05cc4a835', 'Mil Kar Juda Hue To Na Soya Karenge', 869200, 310000, '', 0, '2019-04-30 06:00:23.701891+00', '0'),
	(12721552, '34a2acc9-0193-46a4-899b-df26cdad8223', 'Yeh Mojeza Bhi Mohabbat', 40043, 242000, '', 0, '2019-05-01 06:00:19.053588+00', '0'),
	(12721553, '95facc82-b3e6-43c2-9836-5c0a92c62b4e', 'Dil Ko Gham-E-Hayat', 276197, 221000, '', 0, '2019-04-30 06:00:23.996143+00', '0'),
	(12721554, '41cfa295-75d2-4949-8866-3321ed8ca64f', 'Apne Haton Ki Lakeeron', 40043, 246000, '', 0, '2019-04-30 06:00:24.048389+00', '0'),
	(12721555, 'e5cdc069-661c-451f-8ca4-cd514766e2a5', 'Pareshan Raat Sari Hai', 276197, 292000, '', 0, '2019-05-01 07:00:19.888301+00', '0'),
	(12721556, '9392e422-eb2b-45e6-9b26-b9409bf7493e', 'Angdai Par Angdai Leti', 276197, 218000, '', 0, '2019-05-01 07:00:20.063159+00', '0'),
	(12721557, '8da53062-f0d7-4544-8774-d01c3446cded', 'Sadma To Hai Mujhe Bhi', 276197, 219000, '', 0, '2019-05-01 07:00:20.112233+00', '0'),
	(12721558, '80a91369-65c4-47cb-b7d6-f43463dd2060', 'Tumhari Anjuman Se Uth Ke', 276197, 248000, '', 0, '2019-04-30 06:00:24.148617+00', '0'),
	(12721559, '0d7d32fd-6650-4ef4-9dea-9e5104c9e69b', 'Pahle To Apne Dil Ki Raza', 869200, 278000, '', 0, '2019-05-01 07:00:20.160063+00', '0'),
	(12721560, 'b59c4f3e-901f-4acc-9446-558b91ae4b50', 'Pareshan Raat Sari Hai', 276197, 238000, '', 0, '2019-05-01 07:00:20.305848+00', '0');
INSERT INTO musicbrainz.edit_recording (edit, recording) VALUES
	(60868023, 12721551),
	(60868023, 12721552),
	(60868023, 12721553),
	(60868023, 12721554),
	(60868023, 12721555),
	(60868023, 12721556),
	(60868023, 12721557),
	(60868023, 12721558),
	(60868023, 12721559),
	(60868023, 12721560);
INSERT INTO musicbrainz.release_group (id, gid, name, artist_credit, type, comment, edits_pending, last_updated) VALUES
	(1092944, 'f4dad13b-d85f-4c2b-8268-392773f6bfec', 'Milestone', 40043, 1, '', 0, '2011-09-05 18:33:49.193143+00');
INSERT INTO musicbrainz.release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode, comment, edits_pending, quality, last_updated) VALUES
	(1072194, '5eaf5cfb-8822-48d6-9186-cd429b65f057', 'A Milestone', 869200, 1092944, 1, NULL, 171, 28, NULL, '', 1, -1, '2019-05-01 07:00:20.356137+00'),
	(1608636, '8268eaa7-895d-4787-aaad-56551e00aea5', 'A Milestone', 40043, 1092944, 1, NULL, 171, NULL, NULL, '', 1, -1, '2019-04-30 06:00:24.200204+00');
INSERT INTO musicbrainz.country_area (area) VALUES
	(99);
INSERT INTO musicbrainz.release_country (release, country, date_year, date_month, date_day) VALUES
	(1072194, 99, 1973, NULL, NULL),
	(1608636, 99, 1980, NULL, NULL);
INSERT INTO musicbrainz.area (id, gid, name, type, edits_pending, last_updated, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, ended, comment) VALUES
	(221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1, 0, '2013-05-16 11:06:19.67235+00', NULL, NULL, NULL, NULL, NULL, NULL, '0', '');
INSERT INTO musicbrainz.iso_3166_1 (area, code) VALUES
	(221, 'GB');
INSERT INTO musicbrainz.label (id, gid, name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, label_code, type, area, comment, edits_pending, last_updated, ended) VALUES
	(62793, 'c029628b-6633-439e-bcee-ed02e8a338f7', 'EMI', 1972, NULL, NULL, NULL, NULL, NULL, 542, 4, 221, 'EMI Records, since 1972', 0, '2015-07-05 15:01:16.460867+00', '0');
INSERT INTO musicbrainz.release_label (id, release, label, catalog_number, last_updated) VALUES
	(1139774, 1608636, 62793, 'ECSD 2847', '2015-05-20 15:37:09.874727+00');
INSERT INTO musicbrainz.medium (id, release, position, format, name, edits_pending, last_updated, track_count) VALUES
	(1077041, 1072194, 1, 31, '', 0, '2011-09-05 18:33:49.686445+00', 10),
	(1691721, 1608636, 1, 31, '', 0, '2015-05-20 15:37:10.87034+00', 10);
INSERT INTO musicbrainz.medium_index (medium, toc) VALUES
	(1077041, '(552000, 467000, 292000, 437000, 526000, 238000)');
INSERT INTO musicbrainz.artist_credit (id, name, artist_count, ref_count, created, edits_pending, gid) VALUES
	(2414262, 'Jagjit & Chitra Singh', 1, 2, '2019-05-01 06:00:19.792215+00', 0, '9276e041-1d85-3e46-aaf4-1a7381ab136b');
INSERT INTO musicbrainz.artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
	(2414262, 0, 40043, 'Jagjit & Chitra Singh', '');
INSERT INTO musicbrainz.track (id, gid, recording, medium, position, number, name, artist_credit, length, edits_pending, last_updated, is_data_track) VALUES
	(11140043, 'db1a334d-0924-3293-9234-7a7c851091e5', 12721551, 1077041, 1, '1', 'Yeh Mojeza Bhi Mohabbat Kabhi Dikhaye Mujhe', 40043, 310000, 0, '2019-05-01 06:00:19.792215+00', '0'),
	(11140044, '185354a0-60cb-3dfb-ba9f-6d88f697b2fa', 12721552, 1077041, 2, '2', 'Mil Kar Juda Huwe', 2414262, 242000, 0, '2019-05-01 06:00:19.792215+00', '0'),
	(11140045, '506b063d-d6a0-3b4e-873f-b975e655f94f', 12721553, 1077041, 3, '3', 'Pareshaan Raat Saari Hai', 40043, 221000, 0, '2019-05-01 06:00:19.792215+00', '0'),
	(11140046, 'd7f7b699-4847-3d5b-8c14-efc8ecde87b4', 12721554, 1077041, 4, '4', 'Sadma To Hai Mujhe Bhi Ke Tujhse Juda Hoon Main', 40043, 246000, 0, '2019-05-01 06:00:19.792215+00', '0'),
	(11140047, '7885b2f1-8aeb-33fa-8a2f-3a6006fc8635', 12721555, 1077041, 5, '5', 'Pehle To Apne Dil Ki Raza Jaan Jaiye', 2414262, 292000, 0, '2019-05-01 06:00:19.792215+00', '0'),
	(11140048, 'aaaf0955-1f3f-327b-b698-e5d7bc4c929f', 12721556, 1077041, 6, '6', 'Pareshan Raat Sari Hai', 276197, 218000, 0, '2019-05-01 06:00:19.792215+00', '0'),
	(11140049, 'cf2ab91b-995a-3722-bcd9-9af82036ad9b', 12721557, 1077041, 7, '7', 'Dil Ko Gham-e-Hayat Gawara Hai In Dinon', 276197, 219000, 0, '2019-05-01 06:00:19.792215+00', '0'),
	(11140050, '5d25c80e-6765-3f15-909a-33bd0836d520', 12721558, 1077041, 8, '8', 'Apne Hathon Ki Lakeeron', 40043, 248000, 0, '2019-05-01 06:00:19.792215+00', '0'),
	(11140051, '6eb12bc0-e652-3e6b-9399-4bcb3a6100ff', 12721559, 1077041, 9, '9', 'Angrai Par Angrai Leti Hai Raat Judai Ki', 276197, 278000, 0, '2019-05-01 06:00:19.792215+00', '0'),
	(11140052, '0d034ead-5b44-30c8-847e-46a0da5061c5', 12721560, 1077041, 10, '10', 'Tumhari Anjuman Se Uth Ke Deewane Kahan Jate', 276197, 238000, 0, '2019-05-01 06:00:19.792215+00', '0'),
	(18683659, '1b7978a7-ff6b-48c7-a12a-7fb72ed7f07a', 12721552, 1691721, 1, 'A1', 'Yeh Mojeza Bhi Mohabbat', 40043, NULL, 0, '2019-04-30 06:00:24.200204+00', '0'),
	(18683658, '41b67f5c-e7f5-4796-8234-a5f14759d734', 12721551, 1691721, 2, 'A2', 'Mil Kar Juda Hue To Na Soya Karenge', 869200, NULL, 0, '2019-04-30 06:00:24.200204+00', '0'),
	(18683667, '500c8fe3-0a33-44f9-b606-b18ebffd3d8a', 12721560, 1691721, 3, 'A3', 'Pareshan Raat Sari Hai', 40043, NULL, 0, '2019-04-30 06:00:24.200204+00', '0'),
	(18683664, '00bfbc60-ecf9-4f1f-bb74-722dea12ee63', 12721557, 1691721, 4, 'A4', 'Sadma To Hai Mujhe Bhi', 40043, NULL, 0, '2019-04-30 06:00:24.200204+00', '0'),
	(18683666, '50c5c710-6aeb-494f-8e59-3ee3aefb0ebd', 12721559, 1691721, 5, 'A5', 'Pahle To Apne Dil Ki Raza', 869200, NULL, 0, '2019-04-30 06:00:24.200204+00', '0'),
	(18683662, '0c05a8c5-d708-4cda-af0b-7d2ca836bfff', 12721555, 1691721, 6, 'B1', 'Pareshan Raat Sari Hai', 276197, NULL, 0, '2019-04-30 06:00:24.200204+00', '0'),
	(18683660, 'df035ade-077b-408c-8b5a-7b42e1095fef', 12721553, 1691721, 7, 'B2', 'Dil Ko Gham-E-Hayat', 276197, NULL, 0, '2019-04-30 06:00:24.200204+00', '0'),
	(18683661, '73eb8e3d-c5d3-4f68-9c65-c263023de281', 12721554, 1691721, 8, 'B3', 'Apne Haton Ki Lakeeron', 40043, NULL, 0, '2019-04-30 06:00:24.200204+00', '0'),
	(18683663, 'a89bcdc3-43bc-4780-9a75-6e21cdc2b108', 12721556, 1691721, 9, 'B4', 'Angdai Par Angdai Leti', 276197, NULL, 0, '2019-04-30 06:00:24.200204+00', '0'),
	(18683665, 'a9ee1774-d87b-4469-b0ed-0c36130dce5e', 12721558, 1691721, 10, 'B5', 'Tumhari Anjuman Se Uth Ke', 276197, NULL, 0, '2019-04-30 06:00:24.200204+00', '0');
INSERT INTO musicbrainz.edit_release (edit, release) VALUES
	(60868023, 1072194),
	(60868023, 1608636);
INSERT INTO musicbrainz.edit_release_group (edit, release_group) VALUES
	(60868023, 1092944);
INSERT INTO musicbrainz.edit_artist (edit, artist, status) VALUES
	(60868023, 40043, 1),
	(60868023, 276197, 1);

-- Restore triggers.
CREATE TRIGGER deny_deprecated BEFORE UPDATE OR INSERT ON link FOR EACH ROW EXECUTE PROCEDURE deny_deprecated_links();
