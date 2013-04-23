BEGIN;

SELECT pgq.create_queue('EditorChanges');
SELECT pgq.register_consumer('EditorChanges', 'PasswordHasher');

ALTER TABLE editor ADD COLUMN bcrypt_password VARCHAR(128);

CREATE OR REPLACE FUNCTION rehash_password() RETURNS TRIGGER AS $$
  BEGIN
    PERFORM pgq.insert_event('EditorChanges', 'hash', NEW.name);
    RETURN NULL;
  END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER rehash_password AFTER UPDATE OR INSERT ON editor
FOR EACH ROW EXECUTE PROCEDURE rehash_password();

COMMIT;
