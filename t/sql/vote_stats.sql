SET client_min_messages TO 'warning';

INSERT INTO editor (id, name, password, email, ha1, email_confirm_date, member_since) VALUES
    (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', '16a4862191803cb596ee4b16802bb7ee', now(), now());

INSERT INTO edit (id, type, editor, status, expire_time) VALUES (666, 1, 1, 1, NOW());
INSERT INTO edit_data (edit, data) VALUES (666, '{}');
INSERT INTO vote (editor, vote, vote_time, edit)
    VALUES (1, 1, NOW(), 666),
           (1, 0, NOW(), 666),
           (1, -1, NOW(), 666),
           (1, 1, NOW(), 666),
           (1, 1, '1970-05-10', 666);
