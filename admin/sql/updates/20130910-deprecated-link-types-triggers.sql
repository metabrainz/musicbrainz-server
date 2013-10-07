\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION deny_deprecated_links()
RETURNS trigger AS $$
BEGIN
  IF (TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND OLD.link_type <> NEW.link_type))
    AND (SELECT is_deprecated FROM link_type WHERE id = NEW.link_type)
  THEN
    RAISE EXCEPTION 'Attempt to create or change a relationship into a deprecated relationship type';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER deny_deprecated BEFORE UPDATE OR INSERT ON link
    FOR EACH ROW EXECUTE PROCEDURE deny_deprecated_links();

COMMIT;
