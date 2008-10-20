BEGIN;

CREATE TABLE tag_relation
(
    tag1                INTEGER NOT NULL, -- references tag
    tag2                INTEGER NOT NULL, -- references tag
    weight              INTEGER NOT NULL,
    CHECK (tag1 < tag2)
);

ALTER TABLE tag_relation ADD CONSTRAINT tag_relation_pkey PRIMARY KEY (tag1, tag2);

COMMIT;