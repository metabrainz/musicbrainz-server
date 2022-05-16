\set ON_ERROR_STOP 1

BEGIN;

-- This excludes genre & mood FKs, since those are already being created in
-- separate schema-27 upgrade scripts.

ALTER TABLE documentation.l_area_area_example DROP CONSTRAINT IF EXISTS l_area_area_example_fk_id;
ALTER TABLE documentation.l_area_artist_example DROP CONSTRAINT IF EXISTS l_area_artist_example_fk_id;
ALTER TABLE documentation.l_area_event_example DROP CONSTRAINT IF EXISTS l_area_event_example_fk_id;
ALTER TABLE documentation.l_area_instrument_example DROP CONSTRAINT IF EXISTS l_area_instrument_example_fk_id;
ALTER TABLE documentation.l_area_label_example DROP CONSTRAINT IF EXISTS l_area_label_example_fk_id;
ALTER TABLE documentation.l_area_place_example DROP CONSTRAINT IF EXISTS l_area_place_example_fk_id;
ALTER TABLE documentation.l_area_recording_example DROP CONSTRAINT IF EXISTS l_area_recording_example_fk_id;
ALTER TABLE documentation.l_area_release_example DROP CONSTRAINT IF EXISTS l_area_release_example_fk_id;
ALTER TABLE documentation.l_area_release_group_example DROP CONSTRAINT IF EXISTS l_area_release_group_example_fk_id;
ALTER TABLE documentation.l_area_series_example DROP CONSTRAINT IF EXISTS l_area_series_example_fk_id;
ALTER TABLE documentation.l_area_url_example DROP CONSTRAINT IF EXISTS l_area_url_example_fk_id;
ALTER TABLE documentation.l_area_work_example DROP CONSTRAINT IF EXISTS l_area_work_example_fk_id;
ALTER TABLE documentation.l_artist_artist_example DROP CONSTRAINT IF EXISTS l_artist_artist_example_fk_id;
ALTER TABLE documentation.l_artist_event_example DROP CONSTRAINT IF EXISTS l_artist_event_example_fk_id;
ALTER TABLE documentation.l_artist_instrument_example DROP CONSTRAINT IF EXISTS l_artist_instrument_example_fk_id;
ALTER TABLE documentation.l_artist_label_example DROP CONSTRAINT IF EXISTS l_artist_label_example_fk_id;
ALTER TABLE documentation.l_artist_place_example DROP CONSTRAINT IF EXISTS l_artist_place_example_fk_id;
ALTER TABLE documentation.l_artist_recording_example DROP CONSTRAINT IF EXISTS l_artist_recording_example_fk_id;
ALTER TABLE documentation.l_artist_release_example DROP CONSTRAINT IF EXISTS l_artist_release_example_fk_id;
ALTER TABLE documentation.l_artist_release_group_example DROP CONSTRAINT IF EXISTS l_artist_release_group_example_fk_id;
ALTER TABLE documentation.l_artist_series_example DROP CONSTRAINT IF EXISTS l_artist_series_example_fk_id;
ALTER TABLE documentation.l_artist_url_example DROP CONSTRAINT IF EXISTS l_artist_url_example_fk_id;
ALTER TABLE documentation.l_artist_work_example DROP CONSTRAINT IF EXISTS l_artist_work_example_fk_id;
ALTER TABLE documentation.l_event_event_example DROP CONSTRAINT IF EXISTS l_event_event_example_fk_id;
ALTER TABLE documentation.l_event_instrument_example DROP CONSTRAINT IF EXISTS l_event_instrument_example_fk_id;
ALTER TABLE documentation.l_event_label_example DROP CONSTRAINT IF EXISTS l_event_label_example_fk_id;
ALTER TABLE documentation.l_event_place_example DROP CONSTRAINT IF EXISTS l_event_place_example_fk_id;
ALTER TABLE documentation.l_event_recording_example DROP CONSTRAINT IF EXISTS l_event_recording_example_fk_id;
ALTER TABLE documentation.l_event_release_example DROP CONSTRAINT IF EXISTS l_event_release_example_fk_id;
ALTER TABLE documentation.l_event_release_group_example DROP CONSTRAINT IF EXISTS l_event_release_group_example_fk_id;
ALTER TABLE documentation.l_event_series_example DROP CONSTRAINT IF EXISTS l_event_series_example_fk_id;
ALTER TABLE documentation.l_event_url_example DROP CONSTRAINT IF EXISTS l_event_url_example_fk_id;
ALTER TABLE documentation.l_event_work_example DROP CONSTRAINT IF EXISTS l_event_work_example_fk_id;
ALTER TABLE documentation.l_instrument_instrument_example DROP CONSTRAINT IF EXISTS l_instrument_instrument_example_fk_id;
ALTER TABLE documentation.l_instrument_label_example DROP CONSTRAINT IF EXISTS l_instrument_label_example_fk_id;
ALTER TABLE documentation.l_instrument_place_example DROP CONSTRAINT IF EXISTS l_instrument_place_example_fk_id;
ALTER TABLE documentation.l_instrument_recording_example DROP CONSTRAINT IF EXISTS l_instrument_recording_example_fk_id;
ALTER TABLE documentation.l_instrument_release_example DROP CONSTRAINT IF EXISTS l_instrument_release_example_fk_id;
ALTER TABLE documentation.l_instrument_release_group_example DROP CONSTRAINT IF EXISTS l_instrument_release_group_example_fk_id;
ALTER TABLE documentation.l_instrument_series_example DROP CONSTRAINT IF EXISTS l_instrument_series_example_fk_id;
ALTER TABLE documentation.l_instrument_url_example DROP CONSTRAINT IF EXISTS l_instrument_url_example_fk_id;
ALTER TABLE documentation.l_instrument_work_example DROP CONSTRAINT IF EXISTS l_instrument_work_example_fk_id;
ALTER TABLE documentation.l_label_label_example DROP CONSTRAINT IF EXISTS l_label_label_example_fk_id;
ALTER TABLE documentation.l_label_place_example DROP CONSTRAINT IF EXISTS l_label_place_example_fk_id;
ALTER TABLE documentation.l_label_recording_example DROP CONSTRAINT IF EXISTS l_label_recording_example_fk_id;
ALTER TABLE documentation.l_label_release_example DROP CONSTRAINT IF EXISTS l_label_release_example_fk_id;
ALTER TABLE documentation.l_label_release_group_example DROP CONSTRAINT IF EXISTS l_label_release_group_example_fk_id;
ALTER TABLE documentation.l_label_series_example DROP CONSTRAINT IF EXISTS l_label_series_example_fk_id;
ALTER TABLE documentation.l_label_url_example DROP CONSTRAINT IF EXISTS l_label_url_example_fk_id;
ALTER TABLE documentation.l_label_work_example DROP CONSTRAINT IF EXISTS l_label_work_example_fk_id;
ALTER TABLE documentation.l_place_place_example DROP CONSTRAINT IF EXISTS l_place_place_example_fk_id;
ALTER TABLE documentation.l_place_recording_example DROP CONSTRAINT IF EXISTS l_place_recording_example_fk_id;
ALTER TABLE documentation.l_place_release_example DROP CONSTRAINT IF EXISTS l_place_release_example_fk_id;
ALTER TABLE documentation.l_place_release_group_example DROP CONSTRAINT IF EXISTS l_place_release_group_example_fk_id;
ALTER TABLE documentation.l_place_series_example DROP CONSTRAINT IF EXISTS l_place_series_example_fk_id;
ALTER TABLE documentation.l_place_url_example DROP CONSTRAINT IF EXISTS l_place_url_example_fk_id;
ALTER TABLE documentation.l_place_work_example DROP CONSTRAINT IF EXISTS l_place_work_example_fk_id;
ALTER TABLE documentation.l_recording_recording_example DROP CONSTRAINT IF EXISTS l_recording_recording_example_fk_id;
ALTER TABLE documentation.l_recording_release_example DROP CONSTRAINT IF EXISTS l_recording_release_example_fk_id;
ALTER TABLE documentation.l_recording_release_group_example DROP CONSTRAINT IF EXISTS l_recording_release_group_example_fk_id;
ALTER TABLE documentation.l_recording_series_example DROP CONSTRAINT IF EXISTS l_recording_series_example_fk_id;
ALTER TABLE documentation.l_recording_url_example DROP CONSTRAINT IF EXISTS l_recording_url_example_fk_id;
ALTER TABLE documentation.l_recording_work_example DROP CONSTRAINT IF EXISTS l_recording_work_example_fk_id;
ALTER TABLE documentation.l_release_group_release_group_example DROP CONSTRAINT IF EXISTS l_release_group_release_group_example_fk_id;
ALTER TABLE documentation.l_release_group_series_example DROP CONSTRAINT IF EXISTS l_release_group_series_example_fk_id;
ALTER TABLE documentation.l_release_group_url_example DROP CONSTRAINT IF EXISTS l_release_group_url_example_fk_id;
ALTER TABLE documentation.l_release_group_work_example DROP CONSTRAINT IF EXISTS l_release_group_work_example_fk_id;
ALTER TABLE documentation.l_release_release_example DROP CONSTRAINT IF EXISTS l_release_release_example_fk_id;
ALTER TABLE documentation.l_release_release_group_example DROP CONSTRAINT IF EXISTS l_release_release_group_example_fk_id;
ALTER TABLE documentation.l_release_series_example DROP CONSTRAINT IF EXISTS l_release_series_example_fk_id;
ALTER TABLE documentation.l_release_url_example DROP CONSTRAINT IF EXISTS l_release_url_example_fk_id;
ALTER TABLE documentation.l_release_work_example DROP CONSTRAINT IF EXISTS l_release_work_example_fk_id;
ALTER TABLE documentation.l_series_series_example DROP CONSTRAINT IF EXISTS l_series_series_example_fk_id;
ALTER TABLE documentation.l_series_url_example DROP CONSTRAINT IF EXISTS l_series_url_example_fk_id;
ALTER TABLE documentation.l_series_work_example DROP CONSTRAINT IF EXISTS l_series_work_example_fk_id;
ALTER TABLE documentation.l_url_url_example DROP CONSTRAINT IF EXISTS l_url_url_example_fk_id;
ALTER TABLE documentation.l_url_work_example DROP CONSTRAINT IF EXISTS l_url_work_example_fk_id;
ALTER TABLE documentation.l_work_work_example DROP CONSTRAINT IF EXISTS l_work_work_example_fk_id;
ALTER TABLE documentation.link_type_documentation DROP CONSTRAINT IF EXISTS link_type_documentation_fk_id;

DELETE FROM documentation.l_area_area_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_area_area);
DELETE FROM documentation.l_area_artist_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_area_artist);
DELETE FROM documentation.l_area_event_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_area_event);
DELETE FROM documentation.l_area_instrument_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_area_instrument);
DELETE FROM documentation.l_area_label_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_area_label);
DELETE FROM documentation.l_area_place_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_area_place);
DELETE FROM documentation.l_area_recording_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_area_recording);
DELETE FROM documentation.l_area_release_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_area_release);
DELETE FROM documentation.l_area_release_group_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_area_release_group);
DELETE FROM documentation.l_area_series_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_area_series);
DELETE FROM documentation.l_area_url_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_area_url);
DELETE FROM documentation.l_area_work_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_area_work);
DELETE FROM documentation.l_artist_artist_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_artist_artist);
DELETE FROM documentation.l_artist_event_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_artist_event);
DELETE FROM documentation.l_artist_instrument_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_artist_instrument);
DELETE FROM documentation.l_artist_label_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_artist_label);
DELETE FROM documentation.l_artist_place_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_artist_place);
DELETE FROM documentation.l_artist_recording_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_artist_recording);
DELETE FROM documentation.l_artist_release_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_artist_release);
DELETE FROM documentation.l_artist_release_group_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_artist_release_group);
DELETE FROM documentation.l_artist_series_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_artist_series);
DELETE FROM documentation.l_artist_url_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_artist_url);
DELETE FROM documentation.l_artist_work_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_artist_work);
DELETE FROM documentation.l_event_event_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_event_event);
DELETE FROM documentation.l_event_instrument_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_event_instrument);
DELETE FROM documentation.l_event_label_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_event_label);
DELETE FROM documentation.l_event_place_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_event_place);
DELETE FROM documentation.l_event_recording_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_event_recording);
DELETE FROM documentation.l_event_release_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_event_release);
DELETE FROM documentation.l_event_release_group_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_event_release_group);
DELETE FROM documentation.l_event_series_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_event_series);
DELETE FROM documentation.l_event_url_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_event_url);
DELETE FROM documentation.l_event_work_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_event_work);
DELETE FROM documentation.l_instrument_instrument_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_instrument_instrument);
DELETE FROM documentation.l_instrument_label_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_instrument_label);
DELETE FROM documentation.l_instrument_place_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_instrument_place);
DELETE FROM documentation.l_instrument_recording_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_instrument_recording);
DELETE FROM documentation.l_instrument_release_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_instrument_release);
DELETE FROM documentation.l_instrument_release_group_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_instrument_release_group);
DELETE FROM documentation.l_instrument_series_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_instrument_series);
DELETE FROM documentation.l_instrument_url_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_instrument_url);
DELETE FROM documentation.l_instrument_work_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_instrument_work);
DELETE FROM documentation.l_label_label_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_label_label);
DELETE FROM documentation.l_label_place_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_label_place);
DELETE FROM documentation.l_label_recording_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_label_recording);
DELETE FROM documentation.l_label_release_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_label_release);
DELETE FROM documentation.l_label_release_group_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_label_release_group);
DELETE FROM documentation.l_label_series_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_label_series);
DELETE FROM documentation.l_label_url_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_label_url);
DELETE FROM documentation.l_label_work_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_label_work);
DELETE FROM documentation.l_place_place_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_place_place);
DELETE FROM documentation.l_place_recording_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_place_recording);
DELETE FROM documentation.l_place_release_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_place_release);
DELETE FROM documentation.l_place_release_group_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_place_release_group);
DELETE FROM documentation.l_place_series_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_place_series);
DELETE FROM documentation.l_place_url_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_place_url);
DELETE FROM documentation.l_place_work_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_place_work);
DELETE FROM documentation.l_recording_recording_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_recording_recording);
DELETE FROM documentation.l_recording_release_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_recording_release);
DELETE FROM documentation.l_recording_release_group_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_recording_release_group);
DELETE FROM documentation.l_recording_series_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_recording_series);
DELETE FROM documentation.l_recording_url_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_recording_url);
DELETE FROM documentation.l_recording_work_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_recording_work);
DELETE FROM documentation.l_release_group_release_group_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_release_group_release_group);
DELETE FROM documentation.l_release_group_series_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_release_group_series);
DELETE FROM documentation.l_release_group_url_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_release_group_url);
DELETE FROM documentation.l_release_group_work_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_release_group_work);
DELETE FROM documentation.l_release_release_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_release_release);
DELETE FROM documentation.l_release_release_group_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_release_release_group);
DELETE FROM documentation.l_release_series_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_release_series);
DELETE FROM documentation.l_release_url_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_release_url);
DELETE FROM documentation.l_release_work_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_release_work);
DELETE FROM documentation.l_series_series_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_series_series);
DELETE FROM documentation.l_series_url_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_series_url);
DELETE FROM documentation.l_series_work_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_series_work);
DELETE FROM documentation.l_url_url_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_url_url);
DELETE FROM documentation.l_url_work_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_url_work);
DELETE FROM documentation.l_work_work_example WHERE id NOT IN (SELECT id FROM musicbrainz.l_work_work);
DELETE FROM documentation.link_type_documentation WHERE id NOT IN (SELECT id FROM musicbrainz.link_type);

ALTER TABLE documentation.l_area_area_example
   ADD CONSTRAINT l_area_area_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_area(id);

ALTER TABLE documentation.l_area_artist_example
   ADD CONSTRAINT l_area_artist_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_artist(id);

ALTER TABLE documentation.l_area_event_example
   ADD CONSTRAINT l_area_event_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_event(id);

ALTER TABLE documentation.l_area_instrument_example
   ADD CONSTRAINT l_area_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_instrument(id);

ALTER TABLE documentation.l_area_label_example
   ADD CONSTRAINT l_area_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_label(id);

ALTER TABLE documentation.l_area_place_example
   ADD CONSTRAINT l_area_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_place(id);

ALTER TABLE documentation.l_area_recording_example
   ADD CONSTRAINT l_area_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_recording(id);

ALTER TABLE documentation.l_area_release_example
   ADD CONSTRAINT l_area_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_release(id);

ALTER TABLE documentation.l_area_release_group_example
   ADD CONSTRAINT l_area_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_release_group(id);

ALTER TABLE documentation.l_area_series_example
   ADD CONSTRAINT l_area_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_series(id);

ALTER TABLE documentation.l_area_url_example
   ADD CONSTRAINT l_area_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_url(id);

ALTER TABLE documentation.l_area_work_example
   ADD CONSTRAINT l_area_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_work(id);

ALTER TABLE documentation.l_artist_artist_example
   ADD CONSTRAINT l_artist_artist_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_artist(id);

ALTER TABLE documentation.l_artist_event_example
   ADD CONSTRAINT l_artist_event_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_event(id);

ALTER TABLE documentation.l_artist_instrument_example
   ADD CONSTRAINT l_artist_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_instrument(id);

ALTER TABLE documentation.l_artist_label_example
   ADD CONSTRAINT l_artist_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_label(id);

ALTER TABLE documentation.l_artist_place_example
   ADD CONSTRAINT l_artist_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_place(id);

ALTER TABLE documentation.l_artist_recording_example
   ADD CONSTRAINT l_artist_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_recording(id);

ALTER TABLE documentation.l_artist_release_example
   ADD CONSTRAINT l_artist_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_release(id);

ALTER TABLE documentation.l_artist_release_group_example
   ADD CONSTRAINT l_artist_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_release_group(id);

ALTER TABLE documentation.l_artist_series_example
   ADD CONSTRAINT l_artist_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_series(id);

ALTER TABLE documentation.l_artist_url_example
   ADD CONSTRAINT l_artist_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_url(id);

ALTER TABLE documentation.l_artist_work_example
   ADD CONSTRAINT l_artist_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_work(id);

ALTER TABLE documentation.l_event_event_example
   ADD CONSTRAINT l_event_event_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_event(id);

ALTER TABLE documentation.l_event_instrument_example
   ADD CONSTRAINT l_event_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_instrument(id);

ALTER TABLE documentation.l_event_label_example
   ADD CONSTRAINT l_event_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_label(id);

ALTER TABLE documentation.l_event_place_example
   ADD CONSTRAINT l_event_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_place(id);

ALTER TABLE documentation.l_event_recording_example
   ADD CONSTRAINT l_event_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_recording(id);

ALTER TABLE documentation.l_event_release_example
   ADD CONSTRAINT l_event_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_release(id);

ALTER TABLE documentation.l_event_release_group_example
   ADD CONSTRAINT l_event_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_release_group(id);

ALTER TABLE documentation.l_event_series_example
   ADD CONSTRAINT l_event_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_series(id);

ALTER TABLE documentation.l_event_url_example
   ADD CONSTRAINT l_event_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_url(id);

ALTER TABLE documentation.l_event_work_example
   ADD CONSTRAINT l_event_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_work(id);

ALTER TABLE documentation.l_instrument_instrument_example
   ADD CONSTRAINT l_instrument_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_instrument(id);

ALTER TABLE documentation.l_instrument_label_example
   ADD CONSTRAINT l_instrument_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_label(id);

ALTER TABLE documentation.l_instrument_place_example
   ADD CONSTRAINT l_instrument_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_place(id);

ALTER TABLE documentation.l_instrument_recording_example
   ADD CONSTRAINT l_instrument_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_recording(id);

ALTER TABLE documentation.l_instrument_release_example
   ADD CONSTRAINT l_instrument_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_release(id);

ALTER TABLE documentation.l_instrument_release_group_example
   ADD CONSTRAINT l_instrument_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_release_group(id);

ALTER TABLE documentation.l_instrument_series_example
   ADD CONSTRAINT l_instrument_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_series(id);

ALTER TABLE documentation.l_instrument_url_example
   ADD CONSTRAINT l_instrument_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_url(id);

ALTER TABLE documentation.l_instrument_work_example
   ADD CONSTRAINT l_instrument_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_work(id);

ALTER TABLE documentation.l_label_label_example
   ADD CONSTRAINT l_label_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_label(id);

ALTER TABLE documentation.l_label_place_example
   ADD CONSTRAINT l_label_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_place(id);

ALTER TABLE documentation.l_label_recording_example
   ADD CONSTRAINT l_label_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_recording(id);

ALTER TABLE documentation.l_label_release_example
   ADD CONSTRAINT l_label_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_release(id);

ALTER TABLE documentation.l_label_release_group_example
   ADD CONSTRAINT l_label_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_release_group(id);

ALTER TABLE documentation.l_label_series_example
   ADD CONSTRAINT l_label_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_series(id);

ALTER TABLE documentation.l_label_url_example
   ADD CONSTRAINT l_label_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_url(id);

ALTER TABLE documentation.l_label_work_example
   ADD CONSTRAINT l_label_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_work(id);

ALTER TABLE documentation.l_place_place_example
   ADD CONSTRAINT l_place_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_place(id);

ALTER TABLE documentation.l_place_recording_example
   ADD CONSTRAINT l_place_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_recording(id);

ALTER TABLE documentation.l_place_release_example
   ADD CONSTRAINT l_place_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_release(id);

ALTER TABLE documentation.l_place_release_group_example
   ADD CONSTRAINT l_place_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_release_group(id);

ALTER TABLE documentation.l_place_series_example
   ADD CONSTRAINT l_place_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_series(id);

ALTER TABLE documentation.l_place_url_example
   ADD CONSTRAINT l_place_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_url(id);

ALTER TABLE documentation.l_place_work_example
   ADD CONSTRAINT l_place_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_work(id);

ALTER TABLE documentation.l_recording_recording_example
   ADD CONSTRAINT l_recording_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_recording_recording(id);

ALTER TABLE documentation.l_recording_release_example
   ADD CONSTRAINT l_recording_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_recording_release(id);

ALTER TABLE documentation.l_recording_release_group_example
   ADD CONSTRAINT l_recording_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_recording_release_group(id);

ALTER TABLE documentation.l_recording_series_example
   ADD CONSTRAINT l_recording_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_recording_series(id);

ALTER TABLE documentation.l_recording_url_example
   ADD CONSTRAINT l_recording_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_recording_url(id);

ALTER TABLE documentation.l_recording_work_example
   ADD CONSTRAINT l_recording_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_recording_work(id);

ALTER TABLE documentation.l_release_group_release_group_example
   ADD CONSTRAINT l_release_group_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_group_release_group(id);

ALTER TABLE documentation.l_release_group_series_example
   ADD CONSTRAINT l_release_group_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_group_series(id);

ALTER TABLE documentation.l_release_group_url_example
   ADD CONSTRAINT l_release_group_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_group_url(id);

ALTER TABLE documentation.l_release_group_work_example
   ADD CONSTRAINT l_release_group_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_group_work(id);

ALTER TABLE documentation.l_release_release_example
   ADD CONSTRAINT l_release_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_release(id);

ALTER TABLE documentation.l_release_release_group_example
   ADD CONSTRAINT l_release_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_release_group(id);

ALTER TABLE documentation.l_release_series_example
   ADD CONSTRAINT l_release_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_series(id);

ALTER TABLE documentation.l_release_url_example
   ADD CONSTRAINT l_release_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_url(id);

ALTER TABLE documentation.l_release_work_example
   ADD CONSTRAINT l_release_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_work(id);

ALTER TABLE documentation.l_series_series_example
   ADD CONSTRAINT l_series_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_series_series(id);

ALTER TABLE documentation.l_series_url_example
   ADD CONSTRAINT l_series_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_series_url(id);

ALTER TABLE documentation.l_series_work_example
   ADD CONSTRAINT l_series_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_series_work(id);

ALTER TABLE documentation.l_url_url_example
   ADD CONSTRAINT l_url_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_url_url(id);

ALTER TABLE documentation.l_url_work_example
   ADD CONSTRAINT l_url_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_url_work(id);

ALTER TABLE documentation.l_work_work_example
   ADD CONSTRAINT l_work_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_work_work(id);

ALTER TABLE documentation.link_type_documentation
   ADD CONSTRAINT link_type_documentation_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.link_type(id);

COMMIT;
