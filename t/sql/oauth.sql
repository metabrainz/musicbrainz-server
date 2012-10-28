INSERT INTO editor (id, name, password) VALUES (1, 'editor1', 'pass'), (2, 'editor2', 'pass'), (3, 'editor3', 'pass');

INSERT INTO application (id, owner, name, oauth_id, oauth_secret, oauth_redirect_uri, oauth_confidential)
   VALUES (1, 1, 'Test Desktop', 'id-desktop', 'id-desktop-secret', 'urn:ietf:wg:oauth:2.0:oob', false),
          (2, 1, 'Test Web', 'id-web', 'id-web-secret', 'http://www.example.com/callback', true);

INSERT INTO editor_oauth_token (editor, application, authorization_code, expire_time)
    VALUES (1, 1, 'liUxgzsg4hGvDxX9W8VIuQ', now() + interval '1 hour'),
           (2, 1, 'kEbi7Dwg4hGRFvz9W8VIuQ', now() - interval '1 hour');

INSERT INTO editor_oauth_token (editor, application, refresh_token, access_token, expire_time)
    VALUES (1, 1, 'yi3qjrMf4hG9VVUxXMVIuQ', '7Fjfp0ZBr1KtDRbnfVdmIw', now() + interval '1 hour');

