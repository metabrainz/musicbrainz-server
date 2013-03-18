BEGIN;

SELECT pgq.unregister_consumer('EditorChanges', 'PasswordHasher');
SELECT pgq.drop_queue('EditorChanges');

ALTER TABLE editor ADD COLUMN ha1 CHAR(32);

ALTER TABLE editor
  ALTER COLUMN ha1 TYPE TEXT USING md5(name || ':musicbrainz.org:' || password),
  ALTER COLUMN ha1 SET NOT NULL,
  DROP COLUMN password,
  ALTER COLUMN bcrypt_password SET NOT NULL;

ALTER TABLE editor RENAME bcrypt_password TO password;

COMMIT;
