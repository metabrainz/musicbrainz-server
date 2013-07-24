SET client_min_messages TO 'warning';

INSERT INTO editor (id, name, password, email, ha1, email_confirm_date) VALUES
    (1, 'editor1', '{CLEARTEXT}pass', 'editor1@example.com', '16a4862191803cb596ee4b16802bb7ee', now()),
    (2, 'editor2', '{CLEARTEXT}pass', 'editor2@example.com', 'ba025a52cc5ff57d5d10f31874a83de6', now()),
    (3, 'editor3', '{CLEARTEXT}pass', 'editor3@example.com', 'c096994132d53f3e1cde757943b10e7d', now());
