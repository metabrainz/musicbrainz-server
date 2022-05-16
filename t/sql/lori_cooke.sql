-- release ceb0edd0-550c-4543-8e83-edc92f8ed70c

SET client_min_messages TO 'warning';

-- Temporarily drop triggers.
DROP TRIGGER deny_deprecated ON link;

INSERT INTO musicbrainz.artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, type, area, gender, comment, edits_pending, last_updated, ended, begin_area, end_area) VALUES
	(1744798, 'c369975a-7381-4afd-9c36-1d8fe5115e28', 'Lori Cooke', 'Cooke, Lori', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 2, '', 0, '2019-02-12 04:11:02.224113+00', '0', NULL, NULL);
INSERT INTO musicbrainz.editor (id, name, privs, email, website, bio, member_since, email_confirm_date, last_login_date, last_updated, birth_date, gender, area, password, ha1, deleted) VALUES
	(58244, 'Bitmap', 0, '', NULL, NULL, '2004-08-02 00:10:36.760201+00', '2010-07-11 15:25:29.450044+00', '2019-02-12 07:28:15.904198+00', '2019-02-12 04:24:39.711348+00', NULL, NULL, NULL, '{CLEARTEXT}mb', '0aabee37a3132c87fb2927c91c1799dc', '0');
INSERT INTO musicbrainz.tag (id, name, ref_count) VALUES
	(1440, 'psychobilly', 320);
INSERT INTO musicbrainz.artist_tag_raw (artist, editor, tag, is_upvote) VALUES
	(1744798, 58244, 1440, '1');
INSERT INTO musicbrainz.artist_credit (id, name, artist_count, ref_count, created, gid) VALUES
	(2319047, 'Lori Cooke', 1, 1, '2019-02-12 04:14:14.831564+00', '649c6252-0b9a-3c0b-ae32-57e7a8070566');
INSERT INTO musicbrainz.artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
	(2319047, 0, 1744798, 'Lori Cooke', '');
INSERT INTO musicbrainz.artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, type, area, gender, comment, edits_pending, last_updated, ended, begin_area, end_area) VALUES
	(1744799, '561e53a1-9ae6-4d85-95c0-a39b028eabe4', 'Frances Jones', 'Jones, Frances', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 1, '', 0, '2019-02-12 04:11:38.857794+00', '0', NULL, NULL);
INSERT INTO musicbrainz.tag (id, name, ref_count) VALUES
	(714, 'britpop', 236);
INSERT INTO musicbrainz.artist_tag_raw (artist, editor, tag, is_upvote) VALUES
	(1744799, 58244, 714, '1');
INSERT INTO musicbrainz.artist_credit (id, name, artist_count, ref_count, created, gid) VALUES
	(2319049, 'Lori Cooke & Frances Jones', 2, 1, '2019-02-12 04:14:46.076201+00', '9a245340-2bc7-3981-b386-992d4d27c9d4');
INSERT INTO musicbrainz.artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
	(2319049, 0, 1744798, 'Lori Cooke', ' & '),
	(2319049, 1, 1744799, 'Frances Jones', '');
INSERT INTO musicbrainz.release_group (id, gid, name, artist_credit, type, comment, edits_pending, last_updated) VALUES
	(2069046, '9792a49e-f1e1-4848-8546-82bae03206f6', 'Greatest Hits', 2319049, NULL, '', 0, '2019-02-12 04:14:46.076201+00');
INSERT INTO musicbrainz.tag (id, name, ref_count) VALUES
	(32086, 'doo-wop', 3);
INSERT INTO musicbrainz.release_group_tag_raw (release_group, editor, tag, is_upvote) VALUES
	(2069046, 58244, 32086, '1');
INSERT INTO musicbrainz.release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode, comment, edits_pending, quality, last_updated) VALUES
	(2299278, 'ceb0edd0-550c-4543-8e83-edc92f8ed70c', 'Greatest Hits', 2319047, 2069046, NULL, NULL, NULL, NULL, NULL, '', 0, -1, '2019-02-12 04:14:17.822089+00');
INSERT INTO musicbrainz.medium (id, release, position, format, name, edits_pending, last_updated, track_count) VALUES
	(2486082, 2299278, 1, NULL, '', 0, '2019-02-12 04:14:19.822749+00', 1);
INSERT INTO musicbrainz.artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, type, area, gender, comment, edits_pending, last_updated, ended, begin_area, end_area) VALUES
	(1744801, '9084ad69-7e81-44f9-a195-a522a9b7b08b', 'Leslie Rice', 'Rice, Leslie', NULL, NULL, NULL, NULL, NULL, NULL, 4, NULL, 3, '', 0, '2019-02-12 04:12:10.971646+00', '0', NULL, NULL);
INSERT INTO musicbrainz.tag (id, name, ref_count) VALUES
	(117022, 'post-classical', 0);
INSERT INTO musicbrainz.artist_tag_raw (artist, editor, tag, is_upvote) VALUES
	(1744801, 58244, 117022, '1');
INSERT INTO musicbrainz.artist_credit (id, name, artist_count, ref_count, created, gid) VALUES
	(2319052, 'Lori Cooke, Frances Jones & Leslie Rice', 3, 1, '2019-02-12 05:15:49.014985+00', '79781832-6f41-3d46-b287-31898336b696');
INSERT INTO musicbrainz.artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
	(2319052, 0, 1744798, 'Lori Cooke', ', '),
	(2319052, 1, 1744799, 'Frances Jones', ' & '),
	(2319052, 2, 1744801, 'Leslie Rice', '');
INSERT INTO musicbrainz.recording (id, gid, name, artist_credit, length, comment, edits_pending, last_updated, video) VALUES
	(23684118, 'a3494070-d758-48d4-84c2-80948f5a810b', '10 hours of horn', 2319052, 36000000, '', 0, '2019-02-12 05:15:49.014985+00', '0');
INSERT INTO musicbrainz.tag (id, name, ref_count) VALUES
	(30470, 'freak folk', 3);
INSERT INTO musicbrainz.recording_tag_raw (recording, editor, tag, is_upvote) VALUES
	(23684118, 58244, 30470, '1');
INSERT INTO musicbrainz.artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, type, area, gender, comment, edits_pending, last_updated, ended, begin_area, end_area) VALUES
	(1744800, '95ffd873-9901-4ebd-b07d-eb1fe4485baf', 'Lavone Grimm', 'Grimm, Lavone', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 3, '', 0, '2019-02-12 04:05:04.571866+00', '0', NULL, NULL);
INSERT INTO musicbrainz.tag (id, name, ref_count) VALUES
	(1434, 'blackened death metal', 13);
INSERT INTO musicbrainz.artist_tag_raw (artist, editor, tag, is_upvote) VALUES
	(1744800, 58244, 1434, '1');
INSERT INTO musicbrainz.artist_credit (id, name, artist_count, ref_count, created, gid) VALUES
	(2319051, 'Lori Cooke, Frances Jones & Lavone Grimm', 3, 1, '2019-02-12 05:15:19.278941+00', '1b8dba09-51b9-3aef-8d97-97019f7654ea');
INSERT INTO musicbrainz.artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
	(2319051, 0, 1744798, 'Lori Cooke', ', '),
	(2319051, 1, 1744799, 'Frances Jones', ' & '),
	(2319051, 2, 1744800, 'Lavone Grimm', '');
INSERT INTO musicbrainz.track (id, gid, recording, medium, position, number, name, artist_credit, length, edits_pending, last_updated, is_data_track) VALUES
	(26817940, 'ee78f26a-f14c-44b4-95a6-b3a312985f30', 23684118, 2486082, 1, '1', '10 hours of horn', 2319051, 36000000, 0, '2019-02-12 05:15:19.278941+00', '0');
INSERT INTO musicbrainz.tag (id, name, ref_count) VALUES
	(1137, 'hard bop', 192);
INSERT INTO musicbrainz.release_tag_raw (release, editor, tag, is_upvote) VALUES
	(2299278, 58244, 1137, '1');
INSERT INTO musicbrainz.genre (id, gid, name) VALUES (11, '8a14f570-7297-438d-996d-8797f9b8cfcc', 'psychobilly');
INSERT INTO musicbrainz.genre (id, gid, name) VALUES (12, '8c083468-2dce-4a31-ae77-433af3deafd3', 'hard bop');
INSERT INTO musicbrainz.genre (id, gid, name) VALUES (13, 'f976d48b-965e-4fe9-aaa6-105aab988c7c', 'blackened death metal');
INSERT INTO musicbrainz.genre (id, gid, name) VALUES (14, 'f1c9b874-7ef2-4e79-9419-c0bcb5f33a30', 'britpop');
INSERT INTO musicbrainz.genre (id, gid, name) VALUES (15, '8103927c-5f4b-4bbc-9d8c-7a1241d2bab8', 'freak folk');
INSERT INTO musicbrainz.genre (id, gid, name) VALUES (16, '842008b8-1c67-4c8c-b450-7f5adf20fb7f', 'post-classical');
INSERT INTO musicbrainz.genre (id, gid, name) VALUES (17, '1696f12e-9f01-4309-be9d-116e31ac65b7', 'doo-wop');

-- Restore triggers.
CREATE TRIGGER deny_deprecated BEFORE UPDATE OR INSERT ON link FOR EACH ROW EXECUTE PROCEDURE deny_deprecated_links();
