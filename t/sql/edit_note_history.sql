SET client_min_messages TO 'warning';

INSERT INTO editor (id, name, password, privs, email, ha1, email_confirm_date, member_since) VALUES
(1, 'editor1', '{CLEARTEXT}pass', 0, 'editor1@example.com', '16a4862191803cb596ee4b16802bb7ee', now(), '2014-12-03'),
(2, 'editor2', '{CLEARTEXT}pass', 0, 'editor2@example.com', 'ba025a52cc5ff57d5d10f31874a83de6', now(), '2014-12-04'),
(3, 'admin3', '{CLEARTEXT}pass', 128, 'editor3@example.com', 'c096994132d53f3e1cde757943b10e7d', now(), '2014-12-05');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Name', 'Name');
INSERT INTO edit (id, editor, type, status, expire_time)
    VALUES (1, 1, 32, 1, NOW());
INSERT INTO edit_data (edit, data)
    VALUES (1, '{"entity":{"name":"Name","id":1},"new":{"name":"NewName"},"old":{"name":"Name"}}');
INSERT INTO edit_artist (edit, artist)
    VALUES (1, 1);

INSERT INTO edit_note (id, editor, edit, post_time, text)
    VALUES (1, 1, 1, '2014-12-05', 'This is a fixed note'),
           (2, 2, 1, '2014-12-05', 'This is an untouched answer'),
           (3, 1, 1, '2014-12-05', '');

INSERT INTO edit_note_change (id, status, edit_note, change_editor, change_time, old_note, new_note, reason)
     VALUES (1, 'edited', 1, 1, '2014-12-06', 'This is a messy ntoe', 'This is a messy note', 'typo'),
            (2, 'edited', 1, 1, '2014-12-07', 'This is a messy note', 'This is a fixed note', ''),
            (3, 'deleted', 3, 3, '2016-12-05', 'I HATE YOU ALL', '', 'Unhelpful');
