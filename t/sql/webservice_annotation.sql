INSERT INTO editor (id, name, password, privs, email, website, bio, member_since, email_confirm_date, last_login_date, edits_accepted, edits_rejected, auto_edits_accepted, edits_failed, ha1) VALUES (1, 'webservice', '{CLEARTEXT}password', 1+8+32, 'test@email.com', 'http://test.website', 'biography', '1989-07-23', '2005-10-20', now(), 12, 2, 59, 9, '97d1525140e8ae3e45abf70a5cc366e9');

INSERT INTO annotation (id, editor, text)
        VALUES (1, 1, 'this is an artist annotation'),
               (2, 1, 'this is a label annotation'),
               (3, 1, 'this is a recording annotation'),
               (4, 1, 'this is a release annotation'),
               (5, 1, 'this is a release group annotation'),
               (6, 1, 'this is a work annotation');

INSERT INTO artist_annotation (artist, annotation) VALUES (427385, 1);
INSERT INTO label_annotation (label, annotation) VALUES (46, 2);
INSERT INTO recording_annotation (recording, annotation) VALUES (1542684, 3);
INSERT INTO release_annotation (release, annotation) VALUES (246898, 4);
INSERT INTO release_group_annotation (release_group, annotation) VALUES (597897, 5);
INSERT INTO work_annotation (work, annotation) VALUES (1542684, 6);

