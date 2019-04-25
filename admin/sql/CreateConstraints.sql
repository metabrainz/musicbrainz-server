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

ALTER TABLE editor_collection_type
      ADD CONSTRAINT allowed_collection_entity_type CHECK (
          entity_type IN (
            'area', 'artist', 'event', 'instrument', 'label',
            'place', 'recording', 'release', 'release_group',
            'series', 'work'
          )
      );

ALTER TABLE event
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name));

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

ALTER TABLE release_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE release_group
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE release_group_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE track
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE recording
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE recording_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE series
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE series_type ADD CONSTRAINT allowed_series_entity_type
  CHECK (
    entity_type IN (
      'event',
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

ALTER TABLE medium ADD CONSTRAINT medium_uniq
    UNIQUE (release, position) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE track ADD CONSTRAINT track_uniq_medium_position
    UNIQUE (medium, position) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE l_area_area ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_area ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_area_area ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_area_artist ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_artist ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_area_event ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_event ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_area_instrument ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_instrument ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_area_label ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_label ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_area_place ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_place ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_area_recording ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_recording ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_area_release ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_release ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_area_release_group ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_release_group ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_area_series ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_series ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_area_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_area_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_artist_artist ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_artist ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_artist_artist ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_artist_event ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_event ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_artist_instrument ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_instrument ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_artist_label ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_label ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_artist_place ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_place ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_artist_recording ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_recording ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_artist_release ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_release ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_artist_release_group ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_release_group ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_artist_series ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_series ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_artist_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_artist_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_event_event ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_event_event ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_event_event ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_event_instrument ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_event_instrument ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_event_label ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_event_label ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_event_place ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_event_place ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_event_recording ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_event_recording ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_event_release ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_event_release ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_event_release_group ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_event_release_group ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_event_series ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_event_series ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_event_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_event_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_event_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_event_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_instrument_instrument ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_instrument_instrument ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_instrument_instrument ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_instrument_label ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_instrument_label ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_instrument_place ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_instrument_place ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_instrument_recording ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_instrument_recording ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_instrument_release ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_instrument_release ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_instrument_release_group ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_instrument_release_group ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_instrument_series ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_instrument_series ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_instrument_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_instrument_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_instrument_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_instrument_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_label_label ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_label_label ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_label_label ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_label_place ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_label_place ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_label_recording ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_label_recording ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_label_release ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_label_release ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_label_release_group ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_label_release_group ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_label_series ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_label_series ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_label_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_label_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_label_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_label_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_place_place ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_place_place ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_place_place ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_place_recording ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_place_recording ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_place_release ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_place_release ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_place_release_group ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_place_release_group ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_place_series ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_place_series ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_place_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_place_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_place_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_place_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_recording_recording ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_recording_recording ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_recording_recording ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_recording_release ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_recording_release ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_recording_release_group ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_recording_release_group ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_recording_series ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_recording_series ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_recording_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_recording_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_recording_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_recording_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_release_release ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_release_release ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_release_release ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_release_release_group ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_release_release_group ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_release_series ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_release_series ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_release_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_release_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_release_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_release_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_release_group_release_group ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_release_group_release_group ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_release_group_release_group ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_release_group_series ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_release_group_series ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_release_group_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_release_group_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_release_group_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_release_group_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_series_series ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_series_series ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_series_series ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_series_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_series_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_series_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_series_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_url_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_url_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_url_url ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_url_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_url_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_work_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_work_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_work_work ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

COMMIT;
