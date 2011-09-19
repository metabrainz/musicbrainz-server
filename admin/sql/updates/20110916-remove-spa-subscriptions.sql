BEGIN;

DELETE FROM editor_subscribe_label WHERE label = 1;
DELETE FROM editor_subscribe_artist WHERE artist IN (1, 2);

COMMIT;
