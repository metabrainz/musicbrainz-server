INSERT INTO documentation.link_type_documentation (id, documentation)
    SELECT id, '' AS documentation
      FROM link_type
     WHERE id NOT IN (SELECT id FROM documentation.link_type_documentation);
