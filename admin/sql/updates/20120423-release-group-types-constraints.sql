BEGIN;

ALTER TABLE release_group_secondary_type_join ADD CONSTRAINT
release_group_secondary_type_join_fk_release_group FOREIGN KEY (release_group) REFERENCES release_group (id);

ALTER TABLE release_group_secondary_type_join ADD CONSTRAINT
release_group_secondary_type_join_fk_secondary_type FOREIGN KEY (secondary_type)
REFERENCES release_group_secondary_type (id);

COMMIT;
