SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Setup
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor1', '{CLEARTEXT}pass', '16a4862191803cb596ee4b16802bb7ee'), (2, 'editor2', '{CLEARTEXT}pass', 'ba025a52cc5ff57d5d10f31874a83de6');
INSERT INTO editor_collection (id, gid, editor, name, public)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3cd', 1, 'collection1', TRUE),
           (2, 'f34c079d-374e-4436-9448-da92dedef3cb', 1, 'collection2', TRUE);
ALTER SEQUENCE editor_collection_id_seq RESTART 3;

INSERT INTO editor_subscribe_collection (id, editor, collection, last_edit_sent, available, last_seen_name)
    VALUES (1, 1, 1, 0, TRUE, NULL),
           (2, 1, 2, 0, TRUE, NULL),
           (3, 2, 1, 0, TRUE, NULL),
           (4, 2, 2, 0, TRUE, NULL);

--------------------------------------------------------------------------------
-- Deleting collections should make subscriptions to those collections
-- unavailable
DELETE FROM editor_collection WHERE id = 1;

SELECT bag_eq(
    'SELECT available, last_seen_name FROM editor_subscribe_collection',
    'VALUES (FALSE, ''collection1''), (TRUE, NULL), (FALSE, ''collection1''), (TRUE, NULL)',
    'Subscription availability correctly updated on collection delete'
);

--------------------------------------------------------------------------------
-- Making collections private should make subscriptions to those collections
-- unavailable for other users
UPDATE editor_collection SET public = FALSE WHERE id = 2;

SELECT bag_eq(
    'SELECT available, last_seen_name FROM editor_subscribe_collection',
    'VALUES (FALSE, ''collection1''), (TRUE, NULL), (FALSE, ''collection1''), (FALSE, ''collection2'')',
    'Subscription availability correctly updated on collection hide'
);

--------------------------------------------------------------------------------
-- Inserting new subscriptions to a collection for which an unculled
-- subscription exists should update the existing row
UPDATE editor_collection SET public = TRUE WHERE id = 2;
INSERT INTO editor_subscribe_collection(editor, collection, last_edit_sent) VALUES (2, 2, 2);

SELECT bag_eq(
    'SELECT available, last_seen_name, last_edit_sent FROM editor_subscribe_collection',
    'VALUES (FALSE, ''collection1'', 0), (TRUE, NULL, 0), (FALSE, ''collection1'', 0), (TRUE, NULL, 2)',
    'Update of unculled subscription correctly fires'
);

SELECT finish();
ROLLBACK;
