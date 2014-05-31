\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE area          ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE artist        ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE event         ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE instrument    ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE label         ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE medium        ADD CHECK (controlled_for_whitespace(name));
ALTER TABLE place         ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE recording     ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE release       ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE release_group ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE release_label ADD CHECK (controlled_for_whitespace(catalog_number));
ALTER TABLE series        ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE track         ADD CHECK (controlled_for_whitespace(number));
ALTER TABLE work          ADD CHECK (controlled_for_whitespace(comment));

ALTER TABLE area
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE area_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE artist
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE artist_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE event
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE event_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE artist_credit
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE artist_credit_name
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE instrument
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE instrument_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE label
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE label_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE link_attribute_text_value
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(text_value)),
  ADD CONSTRAINT only_non_empty CHECK (text_value != '');

ALTER TABLE place
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE place_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE release
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE release_group
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE track
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE recording
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE series
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE series_type ADD CONSTRAINT allowed_series_entity_type
  CHECK (
    entity_type IN (
      'recording',
      'release',
      'release_group',
      'work'
    )
  );

ALTER TABLE work
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE work_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE artist
ADD CONSTRAINT group_type_implies_null_gender CHECK (
  (gender IS NULL AND type IN (2, 5, 6))
  OR type NOT IN (2, 5, 6)
  OR type IS NULL
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
