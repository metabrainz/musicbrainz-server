INSERT INTO editor (id, name, password, privs, email, website, bio, email_confirm_date, member_since, last_login_date, ha1)
     VALUES (10, 'eaa_editor', '{CLEARTEXT}password', 0, 'test@editor.org', 'http://musicbrainz.org', 'biography', '2005-10-20', '1989-07-23', now(), 'd139ce6f274698e827dc7b0977cd200f');

INSERT INTO event (id, gid, name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, time, type, cancelled, setlist, comment, ended)
     VALUES (59357, 'ca1d24c1-1999-46fd-8a95-3d4108df5cb2', 'BBC Open Music Prom', 2022, 9, 1, 2022, 9, 1, '19:30:00', 1, 'f', NULL, '2022, Prom 60', 't');

INSERT INTO edit (id, editor, type, status, expire_time)
     VALUES (1, 10, 1510, 2, now());
INSERT INTO edit_data (edit, data)
     VALUES (1, '{}');

INSERT INTO event_art_archive.event_art (id, event, mime_type, edit, ordering)
     VALUES (12345, 59357, 'image/jpeg', 1, 1);
INSERT INTO event_art_archive.event_art_type (id, type_id)
     VALUES (12345, 1);
