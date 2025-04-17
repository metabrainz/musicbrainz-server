\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION delete_unused_url(ids INTEGER[])
RETURNS VOID AS $$
BEGIN
  DELETE FROM url_gid_redirect WHERE new_id = any(ids);
  DELETE FROM url WHERE id = any(ids);
EXCEPTION
  WHEN foreign_key_violation THEN RETURN;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
