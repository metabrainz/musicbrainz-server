BEGIN;

SET client_min_messages TO 'WARNING';

TRUNCATE artist_type CASCADE;

INSERT INTO artist_type (id, name) VALUES (1, 'Person');
INSERT INTO artist_type (id, name) VALUES (2, 'Group');

TRUNCATE country CASCADE;

INSERT INTO country (id, isocode, name) VALUES (1, 'GB', 'United Kingdom');
INSERT INTO country (id, isocode, name) VALUES (2, 'US', 'United States');

TRUNCATE gender CASCADE;

INSERT INTO gender (id, name) VALUES (1, 'Male');
INSERT INTO gender (id, name) VALUES (2, 'Female');

TRUNCATE artist CASCADE;
TRUNCATE artist_name CASCADE;

INSERT INTO artist_name (id, name, page) VALUES (1, 'Artist 1', 1234);
INSERT INTO artist_name (id, name, page) VALUES (2, 'The 2nd Artist', 1234);
INSERT INTO artist_name (id, name, page) VALUES (3, '2nd Artist, The', 1234);
INSERT INTO artist
    (id, gid, name, sortname, type, gender, country,
     begindate_year, begindate_month, begindate_day,
     enddate_year, enddate_month, enddate_day)
    VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1, 1, 1,
     2008, 01, 02, 2009, 03, 04);
INSERT INTO artist (id, gid, name, sortname, type, gender, country) VALUES
    (2, '745c079d-374e-4436-9448-da92dedef3cf', 2, 3, 1, 1, 1);

INSERT INTO artist_name (id, name, page) VALUES (4, 'Queen', 1234);
INSERT INTO artist_name (id, name, page) VALUES (5, 'David Bowie', 1234);

TRUNCATE artist_credit_name CASCADE;
TRUNCATE artist_credit CASCADE;

INSERT INTO artist (id, gid, name, sortname) VALUES
    (3, '945c079d-374e-4436-9448-da92dedef3cf', 4, 4);

INSERT INTO artist_credit (id, artistcount) VALUES (1, 2);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, joinphrase) VALUES (1, 0, 3, 4, ' & ');
INSERT INTO artist_credit_name (artist_credit, position, artist, name, joinphrase) VALUES (1, 1, 3, 5, NULL);

TRUNCATE recording CASCADE;
TRUNCATE track_name CASCADE;

TRUNCATE release_group CASCADE;
TRUNCATE release_group_type CASCADE;
TRUNCATE release_name CASCADE;

INSERT INTO artist_name (id, name, page) VALUES (6, 'ABBA', 1234);

INSERT INTO artist (id, gid, name, sortname) VALUES (4, 'a45c079d-374e-4436-9448-da92dedef3cf', 6, 6);
INSERT INTO artist_credit (id, artistcount) VALUES (2, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name) VALUES (2, 0, 4, 6);

INSERT INTO track_name (id, name, page) VALUES (1, 'Dancing Queen', 1234);
INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (1, '123c079d-374e-4436-9448-da92dedef3ce', 1, 2, 123456);

INSERT INTO release_group_type (id, name) VALUES (1, 'Album');
INSERT INTO release_group_type (id, name) VALUES (2, 'Single');
INSERT INTO release_name (id, name, page) VALUES (1, 'Arrival', 1234);
INSERT INTO release_group (id, gid, name, artist_credit, type) VALUES
    (1, '234c079d-374e-4436-9448-da92dedef3ce', 1, 2, 1);

TRUNCATE work CASCADE;
TRUNCATE work_type CASCADE;
TRUNCATE work_name CASCADE;

INSERT INTO work_type (id, name) VALUES (1, 'Composition');
INSERT INTO work_type (id, name) VALUES (2, 'Symphony');
INSERT INTO work_name (id, name, page) VALUES (1, 'Dancing Queen', 1234);
INSERT INTO work (id, gid, name, artist_credit, type, iswc) VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 2, 1, 'T-000.000.001-0');

TRUNCATE release_status CASCADE;

INSERT INTO release_status (id, name) VALUES (1, 'Official');

TRUNCATE release_packaging CASCADE;

INSERT INTO release_packaging (id, name) VALUES (1, 'Jewel Case');

TRUNCATE language CASCADE;

INSERT INTO language (id, isocode_3t, isocode_3b, isocode_2, name, frequency)
    VALUES (1, 'deu', 'ger', 'de', 'German', 2);

TRUNCATE script CASCADE;

INSERT INTO script (id, isocode, isonumber, name, frequency)
    VALUES (1, 'Ugar', '040', 'Ugaritic', 2);

TRUNCATE label_type CASCADE;

INSERT INTO label_type (id, name) VALUES (1, 'Production');

TRUNCATE label CASCADE;
TRUNCATE label_name CASCADE;

INSERT INTO label_name (id, name, page) VALUES (1, 'Mute', 1234);
INSERT INTO label
    (id, gid, name, sortname, type, country, labelcode,
     begindate_year, begindate_month, begindate_day,
     enddate_year, enddate_month, enddate_day)
    VALUES
    (1, 'f45c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1, 1, 1234,
     2008, 01, 02, 2009, 03, 04);

INSERT INTO label_name (id, name, page) VALUES (2, 'Warp Records', 1234);
INSERT INTO label (id, gid, name, sortname, type, country, labelcode,
                   begindate_year, begindate_month, begindate_day,
                   enddate_year, enddate_month, enddate_day, comment)
     VALUES (2, '46f0f4cd-8aab-4b33-b698-f459faf64190', 2, 2, 1, 1, 2070,
             1989, 02, 03, 2008, 05, 19, 'Sheffield based electronica label');

TRUNCATE release CASCADE;

INSERT INTO release (id, gid, name, artist_credit, release_group, status, packaging, date_year,
                     date_month, date_day, barcode) VALUES
    (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 2, 1, 1, 1, 2009, 5, 8, '731453398122');

TRUNCATE release_label CASCADE;

INSERT INTO release_label (id, release, position, label, catno)
    VALUES (1, 1, 0, 1, 'ABC-123');
INSERT INTO release_label (id, release, position, label, catno)
    VALUES (2, 1, 1, 1, 'ABC-123-X');

TRUNCATE url CASCADE;

INSERT INTO url (id, gid, url, description)
    VALUES (1, '9201840b-d810-4e0f-bb75-c791205f5b24', 'http://musicbrainz.org/', 'MusicBrainz');

TRUNCATE medium_format CASCADE;

INSERT INTO medium_format (id, name) VALUES (1, 'CD');
INSERT INTO medium_format (id, name) VALUES (2, 'Vinyl');

TRUNCATE tracklist CASCADE;

INSERT INTO tracklist (id) VALUES (1);
INSERT INTO tracklist (id) VALUES (2);

TRUNCATE medium CASCADE;

INSERT INTO medium (id, release, position, tracklist, format, name) VALUES (1, 1, 1, 1, 1, 'The First Disc');
INSERT INTO medium (id, release, position, tracklist, format) VALUES (2, 1, 2, 2, 1);

TRUNCATE track CASCADE;

INSERT INTO track (id, recording, tracklist, position, name, artist_credit)
    VALUES (1, 1, 1, 1, 1, 2);

INSERT INTO track_name (id, name, page) VALUES (2, 'Track 2', 1234);
INSERT INTO track (id, recording, tracklist, position, name, artist_credit)
    VALUES (2, 1, 1, 2, 2, 2);

INSERT INTO track_name (id, name, page) VALUES (3, 'Track 3', 1234);
INSERT INTO track (id, recording, tracklist, position, name, artist_credit)
    VALUES (3, 1, 2, 1, 3, 2);

TRUNCATE editor CASCADE;

-- A full editor
INSERT INTO
    editor ( id, name, password, privs, email, website, bio,
             emailconfirmdate, membersince, lastlogindate, editsaccepted, editsrejected,
             autoeditsaccepted, editsfailed)
    VALUES ( 1, 'new_editor', 'password', 1, 'test@editor.org', 'http://musicbrainz.org',
             'biography', '2005-10-20', '1989-07-23', '2009-01-01', 12, 2, 59, 9 );

SET client_min_messages TO 'NOTICE';

COMMIT;