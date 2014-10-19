\set ON_ERROR_STOP 1
BEGIN;

CREATE OR REPLACE FUNCTION a_ins_instrument() RETURNS trigger AS $$
BEGIN
    WITH inserted_rows (id) AS (
        INSERT INTO link_attribute_type (parent, root, child_order, gid, name, description)
        VALUES (14, 14, 0, NEW.gid, NEW.name, NEW.description)
        RETURNING id
    ) INSERT INTO link_creditable_attribute_type (attribute_type) SELECT id FROM inserted_rows;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

INSERT INTO link_creditable_attribute_type
SELECT id AS attribute_type FROM link_attribute_type
WHERE root = 14 AND id not IN (SELECT attribute_type FROM link_creditable_attribute_type);

COMMIT;
