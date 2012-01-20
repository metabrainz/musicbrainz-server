BEGIN;

CREATE INDEX edit_add_relationship_link_type on EDIT (extract_path_value(data, 'link_type/id')) WHERE type = 90;
CREATE INDEX edit_edit_relationship_link_type_link on EDIT (extract_path_value(data, 'link/link_type/id')) WHERE type = 91;
CREATE INDEX edit_edit_relationship_link_type_new on EDIT (extract_path_value(data, 'new/link_type/id')) WHERE type = 91;
CREATE INDEX edit_edit_relationship_link_type_old on EDIT (extract_path_value(data, 'old/link_type/id')) WHERE type = 91;

COMMIT;
