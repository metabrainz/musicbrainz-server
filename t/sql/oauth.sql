INSERT INTO editor (id, name, password) VALUES (1, 'editor1', 'pass'), (2, 'editor2', 'pass'), (3, 'editor3', 'pass');

INSERT INTO application (id, owner, name, oauth_id, oauth_secret, oauth_redirect_uri)
   VALUES (1, 1, 'Test Desktop', 'id-desktop', 'id-desktop-secret', NULL),
          (2, 1, 'Test Web', 'id-web', 'id-web-secret', 'http://www.example.com/callback');

INSERT INTO editor_oauth_token (editor, application, authorization_code, refresh_token, expire_time)
    VALUES (1, 1, 'liUxgzsg4hGvDxX9W8VIuQ', 'dPHMPU-acEUy--Fw_gQfYQ', now() + interval '1 hour'),
           (2, 1, 'kEbi7Dwg4hGRFvz9W8VIuQ', 'bF3aEvwpgZ-ELDemv7wTpA', now() - interval '1 hour');

INSERT INTO editor_oauth_token (editor, application, refresh_token, access_token, expire_time, scope)
    VALUES (1, 1, 'yi3qjrMf4hG9VVUxXMVIuQ', '7Fjfp0ZBr1KtDRbnfVdmIw', now() + interval '1 hour', 1),
           (1, 1, 'uTuPnUfMRQPx8HBnHf22eg', 'Nlaa7v15QHm9g8rUOmT3dQ', now() + interval '1 hour', 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128);

INSERT INTO editor_oauth_token (editor, application, refresh_token, access_token, secret, expire_time, scope)
    VALUES (1, 1, 'Ft-nQZMyDt-oU9Tu2qs9Ow', 'NeYRRMSFFEjRoowpZ1K59Q', 'secret', now() + interval '1 hour', 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128);

