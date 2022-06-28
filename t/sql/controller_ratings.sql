SET client_min_messages TO 'warning';

INSERT INTO editor (id, name, password, ha1)
     VALUES (2, 'alice', '{CLEARTEXT}password', '343cbae85500be826a413b9b6b242669');

-- new_editor (from InsertTestData.sql) has public ratings
UPDATE editor_preference
   SET value = '1'
 WHERE editor = 1
   AND name = 'public_ratings';

-- Alice has private ratings.
INSERT INTO editor_preference (editor, name, value)
     VALUES (2, 'public_ratings', '0');
