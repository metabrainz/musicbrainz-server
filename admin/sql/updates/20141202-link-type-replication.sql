\set ON_ERROR_STOP 1
BEGIN;

-- Lock fairly heavily (though later commands will up this to ACCESS EXCLUSIVE and more tables)
LOCK TABLE link_type IN EXCLUSIVE MODE;

-- Drop replication to insert fake rows
DROP TRIGGER reptg_link_type ON link_type;

-- Copy relevant bits of table to a temporary table
CREATE TEMPORARY TABLE tmp_link_type ON COMMIT DROP AS
    SELECT id, gid, name, description, parent, child_order,
           entity_type0, entity_type1,
           link_phrase, reverse_link_phrase, long_link_phrase,
           priority, last_updated,
           is_deprecated, has_dates,
           entity0_cardinality, entity1_cardinality
      FROM link_type WHERE id > 760;

-- Insert fake rows for missing numbers in the relevant section
INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, long_link_phrase)
SELECT q.id, generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/fake-link-type/' || id::text),
       'artist', 'artist',
       'fake ' || id::text, 'fake link phrase ' || id::text, 'fake reverse link phrase ' || id::text, 'fake long link phrase ' || id::text
  FROM (SELECT generate_series(761, (SELECT max(id) FROM link_type)) AS id EXCEPT SELECT id FROM link_type) q;

-- Re-enable replication
CREATE TRIGGER "reptg_link_type"
AFTER INSERT OR DELETE OR UPDATE ON "link_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

-- Disable FKs that would error
ALTER TABLE link DROP CONSTRAINT IF EXISTS link_fk_link_type;
ALTER TABLE link_type_attribute_type DROP CONSTRAINT IF EXISTS link_type_attribute_type_fk_link_type;
ALTER TABLE documentation.link_type_documentation DROP CONSTRAINT IF EXISTS link_type_documentation_fk_id;
ALTER TABLE link_type DROP CONSTRAINT IF EXISTS link_type_fk_parent;
ALTER TABLE orderable_link_type DROP CONSTRAINT IF EXISTS orderable_link_type_fk_link_type;

-- Delete everything in the relevant section
DELETE FROM link_type WHERE id > 760;

-- Re-insert from the temporary table
INSERT INTO link_type (id, gid, name, description, parent, child_order,
                       entity_type0, entity_type1,
                       link_phrase, reverse_link_phrase, long_link_phrase,
                       priority, last_updated,
                       is_deprecated, has_dates,
                       entity0_cardinality, entity1_cardinality)
SELECT id, gid, name, description, parent, child_order,
       entity_type0, entity_type1,
       link_phrase, reverse_link_phrase, long_link_phrase,
       priority, last_updated,
       is_deprecated, has_dates,
       entity0_cardinality, entity1_cardinality
  FROM tmp_link_type;

-- Turn back on FKs
ALTER TABLE link
   ADD CONSTRAINT link_fk_link_type
   FOREIGN KEY (link_type)
   REFERENCES link_type(id);

ALTER TABLE link_type_attribute_type
   ADD CONSTRAINT link_type_attribute_type_fk_link_type
   FOREIGN KEY (link_type)
   REFERENCES link_type(id);

ALTER TABLE documentation.link_type_documentation
   ADD CONSTRAINT link_type_documentation_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.link_type(id);

ALTER TABLE link_type
   ADD CONSTRAINT link_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES link_type(id);

ALTER TABLE orderable_link_type
   ADD CONSTRAINT orderable_link_type_fk_link_type
   FOREIGN KEY (link_type)
   REFERENCES link_type(id);

COMMIT;

