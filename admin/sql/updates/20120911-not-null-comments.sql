BEGIN;

UPDATE artist SET comment = '' WHERE comment is NULL;
UPDATE label SET comment = '' WHERE comment is NULL;
UPDATE recording SET comment = '' WHERE comment is NULL;
UPDATE release SET comment = '' WHERE comment is NULL;
UPDATE release_raw SET comment = '' WHERE comment is NULL;
UPDATE release_group SET comment = '' WHERE comment is NULL;
UPDATE work SET comment = '' WHERE comment is NULL;

UPDATE artist_credit_name SET join_phrase = '' WHERE join_phrase is NULL;

COMMIT;
