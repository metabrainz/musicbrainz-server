INSERT INTO editor (id, name, password, email, privs, ha1, email_confirm_date)
VALUES (1, 'genre_editor', '{CLEARTEXT}pass', 'genre_editor@example.com', 8, 'c88bfbed8b931a64c5feb069fe03c0c1', now()),
       (2, 'boring_editor', '{CLEARTEXT}pass', 'boring_editor@example.com', 0, 'c88bfbed8b931a64c5feb069fe03c0c2', now());

INSERT INTO genre (id, gid, name)
VALUES (1, 'ceeaa283-5d7b-4202-8d1d-e25d116b2a18', 'alternative rock');