\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE editor_collection_type ( -- replicate
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    parent              INTEGER, -- references editor_collection_type.id
    child_order         INTEGER NOT NULL DEFAULT 0,
    description         TEXT
);

ALTER TABLE editor_collection_type ADD CONSTRAINT editor_collection_type_pkey PRIMARY KEY (id);

ALTER TABLE editor_collection_type
   ADD CONSTRAINT editor_collection_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES editor_collection_type(id);

--CREATE TRIGGER "reptg_editor_collection_type"
--AFTER INSERT OR DELETE OR UPDATE ON "editor_collection_type"
--FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

INSERT INTO editor_collection_type (id, name, child_order) VALUES
	(1, 'Owned music', 1),
	(2, 'Wishlist', 2),
	(3, 'Other', 99);

SELECT setval('editor_collection_type_id_seq', (SELECT MAX(id) FROM editor_collection_type));

ALTER TABLE editor_collection
    ADD COLUMN type INTEGER;

ALTER TABLE editor_collection
   ADD CONSTRAINT editor_collection_fk_type
   FOREIGN KEY (type)
   REFERENCES editor_collection_type(id);

COMMIT;
