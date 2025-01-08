SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Name', 1);

INSERT INTO editor (id, name, password, email, ha1, email_confirm_date, member_since, privs) VALUES
    (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', '16a4862191803cb596ee4b16802bb7ee', now(), now(), 0),
    (2, 'editor2', '{CLEARTEXT}pass', 'editor2@example.com', 'ba025a52cc5ff57d5d10f31874a83de6', now(), '2014-12-01', 0),
    (3, 'editor3', '{CLEARTEXT}pass', 'editor3@example.com', 'c096994132d53f3e1cde757943b10e7d', now(), '2014-12-02', 0),
    -- Reminder: Editor #4 is ModBot
    -- Non-verified editor
    (5, 'editor5', '{CLEARTEXT}pass', null, '01de7bc91330d78a6d0a84033e293f15', null, '2014-12-03', 0),
    -- Beginner editor
    (6, 'editor6', '{CLEARTEXT}pass', 'editor6@example.com', '01de7bc91330d78a6d0a84033e293f11', now(), '2014-12-03', 8192),
    -- Account admin
    (7, 'editor7', '{CLEARTEXT}pass', 'editor7@example.com', '01de7bc91330d78a6d0a84033e293f12', now(), '2014-12-03', 128);
