CREATE INDEX CONCURRENTLY edit_remove_relationship_link_type on EDIT (extract_path_value(data, 'relationship/link/type/id')) WHERE type = 92;
