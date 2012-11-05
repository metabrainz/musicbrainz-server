BEGIN;

ALTER TABLE artist        ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE artist_name   ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE label         ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE label_name    ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE medium        ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE recording     ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE release       ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE release_group ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE release_label ADD CHECK (controlled_for_whitespace(catalog_number));
ALTER TABLE release_name  ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE track         ADD CHECK (controlled_for_whitespace(number));
ALTER TABLE track_name    ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE work          ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE work_name     ADD CHECK (controlled_for_whitespace(name));

ALTER TABLE artist_name ADD CHECK (name != '');
ALTER TABLE label_name ADD CHECK (name != '');
ALTER TABLE release_name ADD CHECK (name != '');
ALTER TABLE track_name ADD CHECK (name != '');
ALTER TABLE work_name ADD CHECK (name != '');

ALTER TABLE artist
ADD CHECK (
  (gender IS NULL AND type = 2)
  OR type IS DISTINCT FROM 2
);

COMMIT;
