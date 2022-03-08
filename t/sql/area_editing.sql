INSERT INTO editor (id, name, password, email, privs, ha1, email_confirm_date)
VALUES (1, 'area_editor', '{CLEARTEXT}pass', 'area_editor@example.com', 256, 'c88bfbed8b931a64c5feb069fe03c0c1', now()),
       (2, 'boring_editor', '{CLEARTEXT}pass', 'boring_editor@example.com', 0, 'c88bfbed8b931a64c5feb069fe03c0c2', now());

INSERT INTO area (begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_date_day, end_date_month, end_date_year, ended, gid, id, last_updated, name, type)
VALUES (NULL, NULL, NULL, '', 0, NULL, NULL, NULL, '0', '29a709d8-0320-493e-8d0c-f2c386662b7f', 5099, '2013-05-24 20:27:13.405462+00', 'Chicago', 3);
