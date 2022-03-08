INSERT INTO editor (id, name, password, email, privs, ha1, email_confirm_date)
VALUES (1, 'instrument_editor', '{CLEARTEXT}pass', 'instrument_editor@example.com', 8, 'c88bfbed8b931a64c5feb069fe03c0c1', now()),
       (2, 'boring_editor', '{CLEARTEXT}pass', 'boring_editor@example.com', 0, 'c88bfbed8b931a64c5feb069fe03c0c2', now());

INSERT INTO instrument (id, gid, name)
VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Minimal Instrument');