\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION deny_deprecated_links()
RETURNS trigger AS $$
BEGIN
  IF (SELECT is_deprecated FROM link_type WHERE id = NEW.link_type)
  THEN
    RAISE EXCEPTION 'Attempt to create a relationship with a deprecated type';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION b_upd_link() RETURNS trigger AS $$
BEGIN
    -- Like artist credits, links are shared across many entities
    -- (relationships) and so are immutable: they can only be inserted
    -- or deleted.
    --
    -- This helps ensure the data integrity of relationships and other
    -- materialized tables that rely on their immutability, like
    -- area_containment.
    RAISE EXCEPTION 'link rows are immutable';
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION b_upd_link_attribute() RETURNS trigger AS $$
BEGIN
    -- Refer to b_upd_link.
    RAISE EXCEPTION 'link_attribute rows are immutable';
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION b_upd_link_attribute_credit() RETURNS trigger AS $$
BEGIN
    -- Refer to b_upd_link.
    RAISE EXCEPTION 'link_attribute_credit rows are immutable';
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION b_upd_link_attribute_text_value() RETURNS trigger AS $$
BEGIN
    -- Refer to b_upd_link.
    RAISE EXCEPTION 'link_attribute_text_value rows are immutable';
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
