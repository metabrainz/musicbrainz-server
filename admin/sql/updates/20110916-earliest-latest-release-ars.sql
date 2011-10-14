BEGIN;

DELETE FROM l_release_release WHERE link IN (SELECT id FROM link WHERE link_type = 7);
DELETE FROM link_attribute WHERE link IN (SELECT id FROM link WHERE link_type = 7);

DELETE FROM link WHERE link_type = 7;
DELETE FROM link_type WHERE id = 7;

COMMIT;
