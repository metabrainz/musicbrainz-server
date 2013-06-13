INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor1', '{CLEARTEXT}pass', '16a4862191803cb596ee4b16802bb7ee'), (2, 'editor2', '{CLEARTEXT}pass', 'ba025a52cc5ff57d5d10f31874a83de6'), (3, 'editor3', '{CLEARTEXT}pass', 'c096994132d53f3e1cde757943b10e7d');

INSERT INTO gender (id, name) VALUES (1, 'female');

UPDATE editor SET website='http://www.mysite.com/', gender=1, email='me@mysite.com', email_confirm_date=now() WHERE id=1;
INSERT INTO editor_preference (editor, name, value) VALUES (1, 'timezone', 'Europe/Bratislava');

INSERT INTO application (id, owner, name, oauth_id, oauth_secret, oauth_redirect_uri)
   VALUES (1, 1, 'Test Desktop', 'id-desktop', 'id-desktop-secret', NULL),
          (2, 1, 'Test Web', 'id-web', 'id-web-secret', 'http://www.example.com/callback');

INSERT INTO editor_oauth_token (editor, application, authorization_code, refresh_token, expire_time)
    VALUES (1, 1, 'liUxgzsg4hGvDxX9W8VIuQ', 'dPHMPU-acEUy--Fw_gQfYQ', now() + interval '1 hour'),
           (2, 1, 'kEbi7Dwg4hGRFvz9W8VIuQ', 'bF3aEvwpgZ-ELDemv7wTpA', now() - interval '1 hour');

INSERT INTO editor_oauth_token (editor, application, refresh_token, access_token, expire_time, scope)
    VALUES (1, 1, 'yi3qjrMf4hG9VVUxXMVIuQ', '7Fjfp0ZBr1KtDRbnfVdmIw', now() + interval '1 hour', 1),
           (1, 1, 'uTuPnUfMRQPx8HBnHf22eg', 'Nlaa7v15QHm9g8rUOmT3dQ', now() + interval '1 hour', 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128),
           (1, 1, 'xi2Aq4235zX32XUx1231u1', '3fxf40Z5r6K78D9b031xaw', now() - interval '1 hour', 1);

INSERT INTO editor_oauth_token (editor, application, refresh_token, access_token, mac_key, expire_time, scope)
    VALUES (1, 1, 'Ft-nQZMyDt-oU9Tu2qs9Ow', 'NeYRRMSFFEjRoowpZ1K59Q', 'secret', now() + interval '1 hour', 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128);

