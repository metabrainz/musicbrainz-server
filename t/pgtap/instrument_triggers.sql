SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

INSERT INTO instrument (id, gid, name, description) VALUES (1, 'd452e3e3-8386-40e0-b04f-b780be2b369a', 'erhu', 'some description');
SELECT is(name, 'erhu') FROM link_attribute_type WHERE gid = 'd452e3e3-8386-40e0-b04f-b780be2b369a';
SELECT is(description, 'some description') FROM link_attribute_type WHERE gid = 'd452e3e3-8386-40e0-b04f-b780be2b369a';

UPDATE instrument SET name = 'shakuhachi', description = 'some other description' WHERE gid = 'd452e3e3-8386-40e0-b04f-b780be2b369a';
SELECT is(name, 'shakuhachi') FROM link_attribute_type WHERE gid = 'd452e3e3-8386-40e0-b04f-b780be2b369a';
SELECT is(description, 'some other description') FROM link_attribute_type WHERE gid = 'd452e3e3-8386-40e0-b04f-b780be2b369a';

DELETE FROM instrument WHERE gid = 'd452e3e3-8386-40e0-b04f-b780be2b369a';
SELECT is_empty('SELECT gid FROM link_attribute_type WHERE gid = ''d452e3e3-8386-40e0-b04f-b780be2b369a''');

SELECT finish();
ROLLBACK;
