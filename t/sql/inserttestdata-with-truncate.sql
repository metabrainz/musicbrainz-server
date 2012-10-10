BEGIN;

SET client_min_messages TO 'WARNING';

TRUNCATE annotation CASCADE;
TRUNCATE artist CASCADE;
TRUNCATE artist_alias CASCADE;
TRUNCATE artist_annotation CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE artist_gid_redirect CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE artist_type CASCADE;
TRUNCATE cdtoc CASCADE;
TRUNCATE clientversion CASCADE;
TRUNCATE country CASCADE;
TRUNCATE editor CASCADE;
TRUNCATE gender CASCADE;
TRUNCATE isrc CASCADE;
TRUNCATE l_artist_recording CASCADE;
TRUNCATE label CASCADE;
TRUNCATE label_alias CASCADE;
TRUNCATE label_annotation CASCADE;
TRUNCATE label_gid_redirect CASCADE;
TRUNCATE label_name CASCADE;
TRUNCATE label_type CASCADE;
TRUNCATE language CASCADE;
TRUNCATE link CASCADE;
TRUNCATE link_attribute CASCADE;
TRUNCATE link_attribute_type CASCADE;
TRUNCATE link_type CASCADE;
TRUNCATE link_type_attribute_type CASCADE;
TRUNCATE medium CASCADE;
TRUNCATE medium_format CASCADE;
TRUNCATE puid CASCADE;
TRUNCATE recording CASCADE;
TRUNCATE recording_annotation CASCADE;
TRUNCATE recording_gid_redirect CASCADE;
TRUNCATE release CASCADE;
TRUNCATE release_annotation CASCADE;
TRUNCATE release_gid_redirect CASCADE;
TRUNCATE release_group CASCADE;
TRUNCATE release_group_annotation CASCADE;
TRUNCATE release_group_gid_redirect CASCADE;
TRUNCATE release_group_primary_type CASCADE;
TRUNCATE release_label CASCADE;
TRUNCATE release_name CASCADE;
TRUNCATE release_packaging CASCADE;
TRUNCATE release_status CASCADE;
TRUNCATE script CASCADE;
TRUNCATE tag CASCADE;
TRUNCATE track CASCADE;
TRUNCATE track_name CASCADE;
TRUNCATE tracklist CASCADE;
TRUNCATE url CASCADE;
TRUNCATE work CASCADE;
TRUNCATE work_annotation CASCADE;
TRUNCATE work_gid_redirect CASCADE;
TRUNCATE work_name CASCADE;
TRUNCATE work_type CASCADE;

INSERT INTO artist_type (id, name) VALUES (1, 'Person');
INSERT INTO artist_type (id, name) VALUES (2, 'Group');
INSERT INTO artist_type (id, name) VALUES (3, 'Special MusicBrainz Artist');

INSERT INTO country (id, iso_code, name) VALUES (1, 'GB', 'United Kingdom');
INSERT INTO country (id, iso_code, name) VALUES (2, 'US', 'United States');

INSERT INTO gender (id, name) VALUES (1, 'Male');
INSERT INTO gender (id, name) VALUES (2, 'Female');

-- MusicBrainz System Entities
INSERT INTO artist_name (id, name) VALUES (1, 'Various Artists');
INSERT INTO artist_name (id, name) VALUES (2, 'Deleted Artist');

INSERT INTO artist (id, gid, name, sort_name, type) VALUES
    (1, '89ad4ac3-39f7-470e-963a-56509c546377', 1, 1, 3);

INSERT INTO artist (id, gid, name, sort_name, type) VALUES
    (2, 'c06aa285-520e-40c0-b776-83d2c9e8a6d1', 2, 2, 3);

-- Test Artist
INSERT INTO artist_name (id, name) VALUES (3, 'Test Artist');
INSERT INTO artist_name (id, name) VALUES (4, 'Artist, Test');
INSERT INTO artist
    (id, gid, name, sort_name, type, gender, country,
     begin_date_year, begin_date_month, begin_date_day,
     end_date_year, end_date_month, end_date_day, comment)
    VALUES
    (3, '745c079d-374e-4436-9448-da92dedef3ce', 3, 4, 1, 1, 1,
     2008, 01, 02, 2009, 03, 04, 'Yet Another Test Artist');

UPDATE artist_meta SET rating=70, rating_count=4 WHERE id=3;

INSERT INTO artist_name (id, name) VALUES (5, 'Queen');
INSERT INTO artist_name (id, name) VALUES (6, 'David Bowie');
INSERT INTO artist_name (id, name) VALUES (104, 'Queen & David Bowie');

INSERT INTO artist (id, gid, name, sort_name) VALUES
    (4, '945c079d-374e-4436-9448-da92dedef3cf', 5, 5);

INSERT INTO artist (id, gid, name, sort_name) VALUES
    (5, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 6, 6);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 104, 2);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES (1, 0, 4, 5, ' & ');
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES (1, 1, 5, 6, '');

-- Test artist name triggers
INSERT INTO artist_name (id, name) VALUES (100, 'Shared Name');
INSERT INTO artist_name (id, name) VALUES (101, 'Name');
INSERT INTO artist_name (id, name) VALUES (102, 'Sort Name');
INSERT INTO artist_name (id, name) VALUES (103, 'Credit Name');
INSERT INTO artist (id, gid, name, sort_name) VALUES (100, '24c94140-456b-11de-8a39-0800200c9a66', 100, 100);
INSERT INTO artist (id, gid, name, sort_name) VALUES (101, '374d65d0-456b-11de-8a39-0800200c9a66', 101, 102);
INSERT INTO artist_credit (id, name, artist_count) VALUES (100, 100, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES (100, 0, 100, 103, '');

INSERT INTO artist_name (id, name) VALUES (7, 'ABBA');

INSERT INTO artist (id, gid, name, sort_name) VALUES (6, 'a45c079d-374e-4436-9448-da92dedef3cf', 7, 7);
INSERT INTO artist_credit (id, name, artist_count) VALUES (2, 7, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name) VALUES (2, 0, 6, 7);

INSERT INTO track_name (id, name) VALUES (1, 'Dancing Queen');
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (1, '123c079d-374e-4436-9448-da92dedef3ce', 1, 2, 123456);

INSERT INTO release_group_primary_type (id, name) VALUES (1, 'Album');
INSERT INTO release_group_primary_type (id, name) VALUES (2, 'Single');
INSERT INTO release_name (id, name) VALUES (1, 'Arrival');
INSERT INTO release_group (id, gid, name, artist_credit, type) VALUES
    (1, '234c079d-374e-4436-9448-da92dedef3ce', 1, 2, 1);

-- Test multiple release groups on a page
INSERT INTO artist_credit (id, name, artist_count) VALUES (4, 3, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name) VALUES (4, 0, 3, 3);

INSERT INTO release_name (id, name) VALUES (3, 'Test RG 1');
INSERT INTO release_name (id, name) VALUES (4, 'Test RG 2');

INSERT INTO release_group (id, gid, name, artist_credit, type) VALUES
    (3, 'ecc33260-454c-11de-8a39-0800200c9a66', 3, 4, 1);

INSERT INTO release_group (id, gid, name, artist_credit, type) VALUES
    (4, '7348f3a0-454e-11de-8a39-0800200c9a66', 4, 4, 1);

INSERT INTO work_type (id, name) VALUES (1, 'Composition');
INSERT INTO work_type (id, name) VALUES (2, 'Symphony');
INSERT INTO work_name (id, name) VALUES (1, 'Dancing Queen');
INSERT INTO work (id, gid, name, artist_credit, type) VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 2, 1);
INSERT INTO iswc (work, iswc) VALUES (1, 'T-000.000.001-0');

INSERT INTO release_status (id, name) VALUES (1, 'Official');
INSERT INTO release_status (id, name) VALUES (2, 'Promotional');

INSERT INTO release_packaging (id, name) VALUES (1, 'Jewel Case');
INSERT INTO release_packaging (id, name) VALUES (2, 'Digipak');

INSERT INTO language (id, iso_code_2t, iso_code_2b, iso_code_1, iso_code_3, name, frequency)
    VALUES (1, 'deu', 'ger', 'de', 'deu', 'German', 2),
           (2, 'lit', 'lit', 'lt', 'lit', 'Lithuanian', 1);

INSERT INTO script (id, iso_code, iso_number, name, frequency)
    VALUES (1, 'Ugar', '040', 'Ugaritic', 2),
           (2, 'Hebr', '125', 'Hebrew', 4);

INSERT INTO label_type (id, name) VALUES (1, 'Production');
INSERT INTO label_type (id, name) VALUES (2, 'Special MusicBrainz Label');

-- Special Labels
INSERT INTO label_name (id, name) VALUES (1, 'Deleted Label');
INSERT INTO label (id, gid, name, sort_name, type) VALUES
    (1, 'f43e252d-9ebf-4e8e-bba8-36d080756cc1', 1, 1, 2);

INSERT INTO label_name (id, name) VALUES (2, 'Warp Records');
INSERT INTO label (id, gid, name, sort_name, type, country, label_code,
                   begin_date_year, begin_date_month, begin_date_day,
                   end_date_year, end_date_month, end_date_day, comment)
     VALUES (2, '46f0f4cd-8aab-4b33-b698-f459faf64190', 2, 2, 1, 1, 2070,
             1989, 02, 03, 2008, 05, 19, 'Sheffield based electronica label');


INSERT INTO label_name (id, name) VALUES (4, 'Another Label');
INSERT INTO label (id, gid, name, sort_name) VALUES
    (3, '4b4ccf60-658e-11de-8a39-0800200c9a66', 4, 4);

INSERT INTO label_name (id, name) VALUES (5, 'Empty Label');
INSERT INTO label (id, gid, name, sort_name) VALUES
    (4, 'f34c079d-374e-4436-9448-da92dedef3ce', 5, 5);

INSERT INTO release (id, gid, name, artist_credit, release_group, status, packaging, date_year,
                     date_month, date_day, barcode, country) VALUES
    (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 2, 1, 1, 1, 2009, 5, 8, '731453398122', 1);

INSERT INTO release_label (id, release, label, catalog_number)
    VALUES (1, 1, 2, 'ABC-123');
INSERT INTO release_label (id, release, label, catalog_number)
    VALUES (2, 1, 2, 'ABC-123-X');

INSERT INTO url (id, gid, url)
    VALUES (1, '9201840b-d810-4e0f-bb75-c791205f5b24', 'http://musicbrainz.org/');

INSERT INTO medium_format (id, name) VALUES (1, 'CD');
INSERT INTO medium_format (id, name) VALUES (2, 'Vinyl');

INSERT INTO tracklist (id) VALUES (1);
INSERT INTO tracklist (id) VALUES (2);

INSERT INTO medium (id, release, position, tracklist, format, name) VALUES (1, 1, 1, 1, 1, 'The First Disc');
INSERT INTO medium (id, release, position, tracklist, format, name) VALUES (2, 1, 2, 2, 1, 'The Second Disc');


INSERT INTO track (id, recording, tracklist, position, number, name, artist_credit, length)
    VALUES (1, 1, 1, 1, 1, 1, 2, 123456);

INSERT INTO track_name (id, name) VALUES (2, 'Track 2');
INSERT INTO track (id, recording, tracklist, position, number, name, artist_credit, length)
    VALUES (2, 1, 1, 2, 2, 2, 2, 123456);

INSERT INTO track_name (id, name) VALUES (3, 'Track 3');
INSERT INTO track (id, recording, tracklist, position, number, name, artist_credit)
    VALUES (3, 1, 2, 1, 1, 3, 2);

-- A full editor
INSERT INTO
    editor ( id, name, password, privs, email, website, bio,
             email_confirm_date, member_since, last_login_date, edits_accepted, edits_rejected,
             auto_edits_accepted, edits_failed)
    VALUES ( 1, 'new_editor', 'password', 0, 'test@editor.org', 'http://musicbrainz.org',
             'biography', '2005-10-20', '1989-07-23', '2009-01-01', 12, 2, 59, 9 );

INSERT INTO editor_preference (editor, name, value) VALUES (1, 'public_ratings', '0');

INSERT INTO artist_name (id, name) VALUES (8, 'Test Alias');
INSERT INTO artist_alias (id, name, sort_name, artist, edits_pending)
    VALUES (1, 8, 8, 4, 2);

INSERT INTO artist_alias (id, name, sort_name, artist)
    VALUES (2, 8, 8, 5);

INSERT INTO label_name (id, name) VALUES (3, 'Test Label Alias');
INSERT INTO label_alias (id, name, sort_name, label, edits_pending)
    VALUES (1, 3, 3, 2, 2);


INSERT INTO artist_name (id, name) VALUES (9, 'Kate Bush');
INSERT INTO artist_name (id, name) VALUES (10, 'Bush, Kate');

INSERT INTO artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, type)
    VALUES (7, '4b585938-f271-45e2-b19a-91c634b5e396', 9, 10, 1958, 7, 30, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (3, 9, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name) VALUES (3, 0, 7, 9);

INSERT INTO release_name (id, name) VALUES (2, 'Aerial');

INSERT INTO release_group (id, gid, name, artist_credit, type) VALUES
    (2, '7c3218d7-75e0-4e8c-971f-f097b6c308c5', 2, 3, 1);

INSERT INTO release
    (id, gid, name, artist_credit, release_group, status, date_year, date_month, date_day, country, barcode)
    VALUES (2, 'f205627f-b70a-409d-adbe-66289b614e80', 2, 3, 2, 1, 2005, 11, 7, 1, '0094634396028');

INSERT INTO release
    (id, gid, name, artist_credit, release_group, status, date_year, date_month, date_day, country, barcode)
    VALUES (3, '9b3d9383-3d2a-417f-bfbb-56f7c15f075b', 2, 3, 2, 1, 2005, 11, 8, 2, '0827969777220');

INSERT INTO release_label (id, release, label, catalog_number)
    VALUES (3, 2, 2, '343 960 2');

INSERT INTO release_label (id, release, label, catalog_number)
    VALUES (4, 3, 2, '82796 97772 2');

INSERT INTO tracklist (id) VALUES (3);
INSERT INTO tracklist (id) VALUES (4);

INSERT INTO track_name (id, name) VALUES (4, 'King of the Mountain');
INSERT INTO track_name (id, name) VALUES (5, 'π');
INSERT INTO track_name (id, name) VALUES (6, 'Bertie');
INSERT INTO track_name (id, name) VALUES (7, 'Mrs. Bartolozzi');
INSERT INTO track_name (id, name) VALUES (8, 'How to Be Invisible');
INSERT INTO track_name (id, name) VALUES (9, 'Joanni');
INSERT INTO track_name (id, name) VALUES (10, 'A Coral Room');

INSERT INTO track_name (id, name) VALUES (11, 'Prelude');
INSERT INTO track_name (id, name) VALUES (12, 'Prologue');
INSERT INTO track_name (id, name) VALUES (13, 'An Architect''s Dream');
INSERT INTO track_name (id, name) VALUES (14, 'The Painter''s Link');
INSERT INTO track_name (id, name) VALUES (15, 'Sunset');
INSERT INTO track_name (id, name) VALUES (16, 'Aerial Tal');
INSERT INTO track_name (id, name) VALUES (17, 'Somewhere in Between');
INSERT INTO track_name (id, name) VALUES (18, 'Nocturn');
INSERT INTO track_name (id, name) VALUES (19, 'Aerial');

INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (2, '54b9d183-7dab-42ba-94a3-7388a66604b8', 4, 3, 293720);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (3, '659f405b-b4ee-4033-868a-0daa27784b89', 5, 3, 369680);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (4, 'ae674299-2824-4500-9516-653ac1bc6f80', 6, 3, 258839);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (5, 'b1d58a57-a0f3-4db8-aa94-868cdc7bc3bb', 7, 3, 358960);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (6, '44f52946-0c98-47ba-ba60-964774db56f0', 8, 3, 332613);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (7, '07614140-8bb8-4db9-9dcc-0917c3a8471b', 9, 3, 296160);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (8, '1eb4f672-5ee3-454f-9a67-db85a4478fea', 10, 3, 372386);

INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (9, '91028302-a466-4557-a19b-a26584564daa', 11, 3, 86186);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (10, '9560a5ac-d980-41fe-be7f-a6cb4a0cd91b', 12, 3, 342306);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (11, '2ed42694-7b28-433e-9cf0-1e14a25babfe', 13, 3, 290053);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (12, '3bf4cbea-f963-4d75-bac5-351a29c60575', 14, 3, 95933);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (13, '33137503-0ebf-4b6b-a7ce-cc71df5865df', 15, 3, 358573);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (14, '2c89d9f6-fd0e-4e79-a654-828fbcf4656d', 16, 3, 61333);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (15, '61b13b9d-e839-4ea9-8453-208eaafb75bf', 17, 3, 300626);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (16, 'd328d709-609c-4b88-90be-95815f041524', 18, 3, 514679);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (17, '1539ac10-5081-4469-b8f2-c5896132724e', 19, 3, 472880);

INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (4, 3, 1, 1, 2, 4, 3, 293720);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (5, 3, 2, 2, 3, 5, 3, 369680);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (6, 3, 3, 3, 4, 6, 3, 258839);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (7, 3, 4, 4, 5, 7, 3, 358960);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (8, 3, 5, 5, 6, 8, 3, 332613);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (9, 3, 6, 6, 7, 9, 3, 296160);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (10, 3, 7, 7, 8, 10, 3, 372386);

INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (11, 4, 1, 1, 9, 11, 3, 86186);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (12, 4, 2, 2, 10, 12, 3, 342306);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (13, 4, 3, 3, 11, 13, 3, 290053);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (14, 4, 4, 4, 12, 14, 3, 95933);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (15, 4, 5, 5, 13, 15, 3, 358573);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (16, 4, 6, 6, 14, 16, 3, 61333);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (17, 4, 7, 7, 15, 17, 3, 300626);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (18, 4, 8, 8, 16, 18, 3, 514679);
INSERT INTO track (id, tracklist, position, number, recording, name, artist_credit, length) VALUES (19, 4, 9, 9, 17, 19, 4, 472880);

INSERT INTO medium (id, release, position, tracklist, format, name) VALUES (3, 2, 1, 3, 1, 'A Sea of Honey');
INSERT INTO medium (id, release, position, tracklist, format, name) VALUES (4, 2, 2, 4, 1, 'A Sky of Honey');

INSERT INTO medium (id, release, position, tracklist, format, name) VALUES (5, 3, 1, 3, 1, 'A Sea of Honey');
INSERT INTO medium (id, release, position, tracklist, format, name) VALUES (6, 3, 2, 4, 1, 'A Sky of Honey');

INSERT INTO isrc (isrc, recording) VALUES ('DEE250800230', 2);

INSERT INTO link_attribute_type (id, root, gid, name)
    VALUES (1, 1, '36990974-4f29-4ea1-b562-3838fa9b8832', 'additional');
INSERT INTO link_attribute_type (id, root, gid, name)
    VALUES (2, 2, '108d76bd-95eb-4099-aed6-447e4ec78553', 'instrument');
INSERT INTO link_attribute_type (id, parent, root, gid, name)
    VALUES (3, 2, 2, '4f7bb10f-396c-466a-8221-8e93f5e454f9', 'String Instruments');
INSERT INTO link_attribute_type (id, parent, root, gid, name)
    VALUES (4, 3, 2, 'c3273296-91ba-453d-94e4-2fb6e958568e', 'Guitar');

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, short_link_phrase)
    VALUES (1, '7610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'recording', 'instrument',
            'performed {additional} {instrument} on',
            'has {additional} {instrument} performed by',
            'performer');

INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max)
    VALUES (1, 1, 0, 1);
INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max)
    VALUES (1, 2, 1, NULL);

INSERT INTO link (id, link_type, attribute_count) VALUES (1, 1, 1);
INSERT INTO link (id, link_type, attribute_count) VALUES (2, 1, 2);

INSERT INTO link_attribute (link, attribute_type) VALUES (1, 4);
INSERT INTO link_attribute (link, attribute_type) VALUES (2, 1);
INSERT INTO link_attribute (link, attribute_type) VALUES (2, 3);

INSERT INTO artist (id, gid, name, sort_name)
    VALUES
    (8, 'e2a083a9-9942-4d6e-b4d2-8397320b95f7', 8, 9);
INSERT INTO artist (id, gid, name, sort_name) VALUES
    (9, '2fed031c-0e89-406e-b9f0-3d192637907a', 8, 9);

INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (1, 1, 8, 2);
INSERT INTO l_artist_recording (id, link, entity0, entity1, edits_pending) VALUES (2, 1, 9, 2, 1);
INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (3, 2, 8, 3);

INSERT INTO annotation (id, editor, text) VALUES (1, 1, 'Test annotation 1' || chr(10) || chr(10) || 'More annotation');
INSERT INTO annotation (id, editor, text) VALUES (2, 1, 'Test annotation 2.');
INSERT INTO annotation (id, editor, text) VALUES (3, 1, 'Test annotation 3.');
INSERT INTO annotation (id, editor, text) VALUES (4, 1, 'Test annotation 4.');
INSERT INTO annotation (id, editor, text) VALUES (5, 1, 'Test annotation 5.');
INSERT INTO annotation (id, editor, text) VALUES (6, 1, 'Test annotation 6.');
INSERT INTO annotation (id, editor, text) VALUES (7, 1, 'Test annotation 7.');

INSERT INTO artist_annotation (artist, annotation) VALUES (3, 1);
INSERT INTO artist_annotation (artist, annotation) VALUES (4, 7);
INSERT INTO label_annotation (label, annotation) VALUES (2, 2);
INSERT INTO recording_annotation (recording, annotation) VALUES (1, 3);
INSERT INTO release_annotation (release, annotation) VALUES (1, 4);
INSERT INTO release_group_annotation (release_group, annotation) VALUES (1, 5);
INSERT INTO work_annotation (work, annotation) VALUES (1, 6);

INSERT INTO artist_gid_redirect VALUES ('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11', 4);
INSERT INTO label_gid_redirect VALUES ('efdf3fe9-c293-4acd-b4b2-8d2a7d4f9592', 2);
INSERT INTO recording_gid_redirect VALUES ('0986e67c-6b7a-40b7-b4ba-c9d7583d6426', 1);
INSERT INTO release_gid_redirect VALUES ('71dc55d8-0fc6-41c1-94e0-85ff2404997d', 1);
INSERT INTO release_group_gid_redirect VALUES ('77637e8c-be66-46ea-87b3-73addc722fc9', 1);
INSERT INTO work_gid_redirect VALUES ('28e73402-5666-4d74-80ab-c3734dc699ea', 1);

INSERT INTO clientversion (id, version) VALUES (1, 'mb_client/1.0');
INSERT INTO puid (id, puid, version) VALUES
    (1, 'b9c8f51f-cc9a-48fa-a415-4c91fcca80f0', 1),
    (2, '134478d1-306e-41a1-8b37-ff525e53c8be', 1);

INSERT INTO recording_puid (id, recording, puid) VALUES
    (1, 1, 1), (2, 1, 2);

INSERT INTO tag (id, name) VALUES (1, 'musical'), (2, 'not-used');
INSERT INTO artist_tag (tag, artist, count) VALUES (1, 3, 2);
INSERT INTO label_tag (tag, label, count) VALUES (1, 2, 2);
INSERT INTO recording_tag (tag, recording, count) VALUES (1, 1, 2);
INSERT INTO release_group_tag (tag, release_group, count) VALUES (1, 1, 2);
INSERT INTO work_tag (tag, work, count) VALUES (1, 1, 2);

INSERT INTO cdtoc (id, discid, freedb_id, track_count, leadout_offset, track_offset) VALUES
    (2, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-', '5908ea07', 7, 171327,
     ARRAY[150,22179,49905,69318,96240,121186,143398]);
INSERT INTO medium_cdtoc (id, medium, cdtoc) VALUES
    (1, 3, 2);

-- Restart sequences
ALTER SEQUENCE gender_id_seq RESTART 3;
ALTER SEQUENCE artist_id_seq RESTART 10;
ALTER SEQUENCE artist_credit_id_seq RESTART 5;
ALTER SEQUENCE label_id_seq RESTART 5;
ALTER SEQUENCE medium_id_seq RESTART 7;
ALTER SEQUENCE recording_id_seq RESTART 18;
ALTER SEQUENCE release_id_seq RESTART 4;
ALTER SEQUENCE release_group_id_seq RESTART 5;
ALTER SEQUENCE work_id_seq RESTART 2;

ALTER SEQUENCE artist_name_id_seq RESTART 11;
ALTER SEQUENCE label_name_id_seq RESTART 6;
ALTER SEQUENCE release_name_id_seq RESTART 5;
ALTER SEQUENCE track_name_id_seq RESTART 20;
ALTER SEQUENCE work_name_id_seq RESTART 2;

ALTER SEQUENCE annotation_id_seq RESTART 8;

ALTER SEQUENCE artist_alias_id_seq RESTART 8;
ALTER SEQUENCE label_alias_id_seq RESTART 8;
ALTER SEQUENCE track_id_seq RESTART 20;
ALTER SEQUENCE medium_id_seq RESTART 7;

ALTER SEQUENCE tag_id_seq RESTART 100;

SET client_min_messages TO 'NOTICE';

COMMIT;
