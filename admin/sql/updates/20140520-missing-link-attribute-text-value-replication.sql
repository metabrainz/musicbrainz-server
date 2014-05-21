\set ON_ERROR_STOP 1
BEGIN;

-- Lock the motherfuckers
LOCK TABLE link_attribute_text_value IN ACCESS EXCLUSIVE MODE;
LOCK TABLE series IN ACCESS EXCLUSIVE MODE; -- ;_; but this is taken by alter table, so this'd happen anyway
LOCK TABLE orderable_link_type IN ACCESS EXCLUSIVE MODE;

LOCK TABLE link_text_attribute_type IN EXCLUSIVE MODE;

-- Add PK so orderable_link_type can be replicated at all
ALTER TABLE orderable_link_type ADD CONSTRAINT orderable_link_type_pkey PRIMARY KEY (link_type);

-- Drop FKs that would be broken
ALTER TABLE link_attribute_text_value DROP CONSTRAINT link_attribute_text_value_fk_attribute_type;
ALTER TABLE series DROP CONSTRAINT series_fk_ordering_attribute;

-- Copy data to temporary tables set ON COMMIT DROP
CREATE TEMPORARY TABLE tmp_link_attribute_text_value (link, attribute_type, text_value) ON COMMIT DROP
  AS SELECT link, attribute_type, text_value FROM link_attribute_text_value;
CREATE TEMPORARY TABLE tmp_link_text_attribute_type (attribute_type) ON COMMIT DROP
  AS SELECT attribute_type FROM link_text_attribute_type;
CREATE TEMPORARY TABLE tmp_orderable_link_type (link_type, direction) ON COMMIT DROP
  AS SELECT link_type, direction FROM orderable_link_type;

-- Create replication triggers
CREATE TRIGGER "reptg_link_attribute_text_value"
AFTER INSERT OR DELETE OR UPDATE ON "link_attribute_text_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_link_text_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "link_text_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_orderable_link_type"
AFTER INSERT OR DELETE OR UPDATE ON "orderable_link_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

-- Delete from tables and reinsert;
-- those with existing data from a post-schema import will need the delete, and everyone needs the insert
DELETE FROM link_attribute_text_value;
INSERT INTO link_attribute_text_value (link, attribute_type, text_value) SELECT link, attribute_type, text_value FROM tmp_link_attribute_text_value;

DELETE FROM link_text_attribute_type;
INSERT INTO link_text_attribute_type (attribute_type) SELECT attribute_type FROM tmp_link_text_attribute_type;

DELETE FROM orderable_link_type;
INSERT INTO orderable_link_type (link_type, direction) SELECT link_type, direction FROM tmp_orderable_link_type;

-- Re-add FKs
ALTER TABLE link_attribute_text_value
   ADD CONSTRAINT link_attribute_text_value_fk_attribute_type
   FOREIGN KEY (attribute_type)
   REFERENCES link_text_attribute_type(attribute_type);

ALTER TABLE series
   ADD CONSTRAINT series_fk_ordering_attribute
   FOREIGN KEY (ordering_attribute)
   REFERENCES link_text_attribute_type(attribute_type);

COMMIT;
