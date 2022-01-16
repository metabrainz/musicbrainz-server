SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Name', 1);

INSERT INTO editor (id, name, password, email, ha1, email_confirm_date, member_since) VALUES
    (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', '16a4862191803cb596ee4b16802bb7ee', now(), now()),
    (2, 'editor2', '{CLEARTEXT}pass', 'editor2@example.com', 'ba025a52cc5ff57d5d10f31874a83de6', now(), '2014-12-01'),
    (3, 'editor3', '{CLEARTEXT}pass', 'editor3@example.com', 'c096994132d53f3e1cde757943b10e7d', now(), '2014-12-02'),
    -- Reminder: Editor #4 is ModBot
    (5, 'editor5', '{CLEARTEXT}pass', 'editor5@example.com', '01de7bc91330d78a6d0a84033e293f15', now(), '2014-12-03');

-- Dummy edits to allow voting
INSERT INTO edit (id, editor, type, status, expire_time)
    SELECT x, 2, 1, 2, now() FROM generate_series(1, 10) x;
INSERT INTO edit_data (edit, data)
    SELECT x, '{}' FROM generate_series(1, 10) x;

INSERT INTO edit (id, editor, type, status, expire_time)
    SELECT x, 3, 1, 2, now() FROM generate_series(11, 20) x;
INSERT INTO edit_data (edit, data)
    SELECT x, '{}' FROM generate_series(11, 20) x;
