\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE link_creditable_attribute_type (
  attribute_type INT NOT NULL PRIMARY KEY
);

CREATE TABLE link_attribute_credit (
  link INT NOT NULL, -- PK, references link.id
  attribute_type INT NOT NULL, -- PK, references link_creditable_attribute_type
  credited_as TEXT NOT NULL,
  PRIMARY KEY (link, attribute_type)
);

INSERT INTO link_creditable_attribute_type (attribute_type)
SELECT id FROM link_attribute_type
WHERE root IN (3, 14);

COMMIT;
