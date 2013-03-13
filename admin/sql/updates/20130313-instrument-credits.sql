\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE link_creditable_attribute_type (
  attribute_type INT NOT NULL -- PK, references link_attribute_type.id
);

CREATE TABLE link_attribute_credit (
  link INT NOT NULL, -- PK, references link.id
  attribute_type INT NOT NULL, -- PK, references link_creditable_attribute_type
  credited_as TEXT NOT NULL
);

INSERT INTO link_creditable_attribute_type (attribute_type) VALUES (3), (14); -- vocal, instrument

COMMIT;
