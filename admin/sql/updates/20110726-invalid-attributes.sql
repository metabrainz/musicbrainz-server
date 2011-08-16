BEGIN;

DELETE FROM link_attribute WHERE (link, attribute_type) NOT IN (
    SELECT la.link, la.attribute_type FROM link_attribute la
    JOIN link l ON l.id = la.link
    JOIN link_type lt ON l.link_type = lt.id
    JOIN link_attribute_type lat ON lat.id = la.attribute_type
    JOIN link_type_attribute_type ltat ON ltat.attribute_type = lat.root AND ltat.link_type = lt.id
);

CREATE OR REPLACE FUNCTION prevent_invalid_attributes()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT TRUE
        FROM (VALUES (NEW.link, NEW.attribute_type)) la (link, attribute_type)
        JOIN link l ON l.id = la.link
        JOIN link_type lt ON l.link_type = lt.id
        JOIN link_attribute_type lat ON lat.id = la.attribute_type
        JOIN link_type_attribute_type ltat ON ltat.attribute_type = lat.root AND ltat.link_type = lt.id
    ) THEN
        RAISE EXCEPTION 'Attribute type % is invalid for link %', NEW.attribute_type, NEW.link;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER b_upd_link_attribute BEFORE UPDATE OR INSERT ON link_attribute
    FOR EACH ROW EXECUTE PROCEDURE prevent_invalid_attributes();

COMMIT;
