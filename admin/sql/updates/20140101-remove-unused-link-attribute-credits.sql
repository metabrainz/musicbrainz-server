\set ON_ERROR_STOP 1
BEGIN;

CREATE OR REPLACE FUNCTION remove_unused_links()
RETURNS TRIGGER AS $$
DECLARE
    other_ars_exist BOOLEAN;
BEGIN
    EXECUTE 'SELECT EXISTS (SELECT TRUE FROM ' || quote_ident(TG_TABLE_NAME) ||
            ' WHERE link = $1)'
    INTO other_ars_exist
    USING OLD.link;

    IF NOT other_ars_exist THEN
       DELETE FROM link_attribute WHERE link = OLD.link;
       DELETE FROM link_attribute_credit WHERE link = OLD.link;
       DELETE FROM link WHERE id = OLD.link;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
