INSERT INTO editor (id, name, password, ha1) VALUES
    (11, 'editor1', '{CLEARTEXT}pass', '16a4862191803cb596ee4b16802bb7ee'),
    (12, 'editor2', '{CLEARTEXT}pass', 'ba025a52cc5ff57d5d10f31874a83de6'),
    (13, 'editor3', '{CLEARTEXT}pass', 'c096994132d53f3e1cde757943b10e7d'),
    (14, 'æditorⅣ', '{CLEARTEXT}pass', 'cee82955d47bf0bd71038244579e766f');

UPDATE editor SET website='http://www.mysite.com/', gender=1, email='me@mysite.com', email_confirm_date=now() WHERE id=11;
INSERT INTO editor_preference (editor, name, value) VALUES (11, 'timezone', 'Europe/Bratislava');

INSERT INTO application (id, owner, name, oauth_id, oauth_secret, oauth_redirect_uri)
   VALUES (1, 11, 'Test Desktop', 'id-desktop', 'id-desktop-secret', NULL),
          (2, 11, 'Test Web', 'id-web', 'id-web-secret', 'http://www.example.com/callback');

INSERT INTO editor_oauth_token (editor, application, authorization_code, refresh_token, expire_time)
    VALUES (11, 1, 'liUxgzsg4hGvDxX9W8VIuQ', 'dPHMPU-acEUy--Fw_gQfYQ', now() + interval '1 hour'),
           (12, 1, 'kEbi7Dwg4hGRFvz9W8VIuQ', 'bF3aEvwpgZ-ELDemv7wTpA', now() - interval '1 hour');

INSERT INTO editor_oauth_token (editor, application, refresh_token, access_token, expire_time, scope)
    VALUES (11, 1, 'yi3qjrMf4hG9VVUxXMVIuQ', '7Fjfp0ZBr1KtDRbnfVdmIw', now() + interval '1 hour', 1),
           (11, 1, 'uTuPnUfMRQPx8HBnHf22eg', 'Nlaa7v15QHm9g8rUOmT3dQ', now() + interval '1 hour', 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128),
           (11, 1, 'xi2Aq4235zX32XUx1231u1', '3fxf40Z5r6K78D9b031xaw', now() - interval '1 hour', 1),
           (14, 1, 'r29KLDbKINaCcrEEpv89XA', 'h_UngEx7VcA6I-XybPS13Q', now() + interval '1 hour', 1);

INSERT INTO editor_collection (gid, editor, name, public, type)
    VALUES ('181685d4-a23a-4140-a343-b7d15de26ff7', 11, 'editor1''s super secret collection', FALSE, 1);
