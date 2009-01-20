BEGIN;

ALTER TABLE tag_relation
    ADD CONSTRAINT tag_relation_fk_tag1
    FOREIGN KEY (tag1)
    REFERENCES tag(id)
    ON DELETE CASCADE;

ALTER TABLE tag_relation
    ADD CONSTRAINT tag_relation_fk_tag2
    FOREIGN KEY (tag2)
    REFERENCES tag(id)
    ON DELETE CASCADE;

COMMIT;