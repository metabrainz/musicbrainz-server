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

ALTER TABLE release_label
ADD CHECK (catalog_number IS NOT NULL OR label IS NOT NULL);

ALTER TABLE artist ADD CONSTRAINT artist_va_check
    CHECK (id <> 1 OR
           (type = 3 AND
            gender IS NULL AND
            area IS NULL AND
            begin_area IS NULL AND
            end_area IS NULL AND
            begin_date_year IS NULL AND
            begin_date_month IS NULL AND
            begin_date_day IS NULL AND
            end_date_year IS NULL AND
            end_date_month IS NULL AND
            end_date_day IS NULL));

ALTER TABLE release_unknown_country ADD CONSTRAINT non_empty_date
    CHECK (date_year IS NOT NULL OR date_month IS NOT NULL OR date_day IS NOT NULL);

COMMIT;
