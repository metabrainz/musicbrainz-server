SET client_min_messages TO 'warning';

INSERT INTO editor (id, name, password, email, ha1, email_confirm_date, member_since) VALUES
(1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', '16a4862191803cb596ee4b16802bb7ee', now(), '2014-12-03'),
(2, 'editor2', '{CLEARTEXT}pass', 'editor2@example.com', 'ba025a52cc5ff57d5d10f31874a83de6', now(), '2014-12-04'),
(3, 'editor3', '{CLEARTEXT}pass', 'editor3@example.com', 'c096994132d53f3e1cde757943b10e7d', now(), '2014-12-05');

-- Test multiple edit_notes
INSERT INTO edit (id, editor, type, status, expire_time)
    VALUES (1, 1, 111, 1, NOW());

INSERT INTO edit_note (id, editor, edit, text)
    VALUES (1, 1, 1, 'This is a note');

INSERT INTO edit_note (id, editor, edit, text)
    VALUES (2, 2, 1, 'This is a later note');

-- Test a single note
INSERT INTO edit (id, editor, type, status, expire_time)
    VALUES (2, 1, 111, 1, NOW());

INSERT INTO edit_note (id, editor, edit, text)
    VALUES (3, 1, 2, 'Another edit note');

-- Test no edit_notes
INSERT INTO edit (id, editor, type, status, expire_time)
    VALUES (3, 1, 111, 1, NOW());

INSERT INTO edit_data (edit, data) SELECT generate_series(1, 3), '{ "foo": "5" }';

-- Dummy edits to allow editor 2 to vote
INSERT INTO edit (id, editor, type, status, expire_time)
    SELECT 3 + x, 2, 111, 2, now() FROM generate_series(1, 10) x;
INSERT INTO edit_data (edit, data)
    SELECT 3 + x, '{}' FROM generate_series(1, 10) x;

ALTER SEQUENCE edit_note_id_seq RESTART 4;
