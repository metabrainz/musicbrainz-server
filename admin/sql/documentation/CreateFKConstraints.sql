-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'documentation';

ALTER TABLE l_area_area_example
   ADD CONSTRAINT l_area_area_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_area(id);

ALTER TABLE l_area_artist_example
   ADD CONSTRAINT l_area_artist_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_artist(id);

ALTER TABLE l_area_event_example
   ADD CONSTRAINT l_area_event_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_event(id);

ALTER TABLE l_area_genre_example
   ADD CONSTRAINT l_area_genre_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_genre(id);

ALTER TABLE l_area_instrument_example
   ADD CONSTRAINT l_area_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_instrument(id);

ALTER TABLE l_area_label_example
   ADD CONSTRAINT l_area_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_label(id);

ALTER TABLE l_area_mood_example
   ADD CONSTRAINT l_area_mood_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_mood(id);

ALTER TABLE l_area_place_example
   ADD CONSTRAINT l_area_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_place(id);

ALTER TABLE l_area_recording_example
   ADD CONSTRAINT l_area_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_recording(id);

ALTER TABLE l_area_release_example
   ADD CONSTRAINT l_area_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_release(id);

ALTER TABLE l_area_release_group_example
   ADD CONSTRAINT l_area_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_release_group(id);

ALTER TABLE l_area_series_example
   ADD CONSTRAINT l_area_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_series(id);

ALTER TABLE l_area_url_example
   ADD CONSTRAINT l_area_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_url(id);

ALTER TABLE l_area_work_example
   ADD CONSTRAINT l_area_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_work(id);

ALTER TABLE l_artist_artist_example
   ADD CONSTRAINT l_artist_artist_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_artist(id);

ALTER TABLE l_artist_event_example
   ADD CONSTRAINT l_artist_event_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_event(id);

ALTER TABLE l_artist_genre_example
   ADD CONSTRAINT l_artist_genre_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_genre(id);

ALTER TABLE l_artist_instrument_example
   ADD CONSTRAINT l_artist_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_instrument(id);

ALTER TABLE l_artist_label_example
   ADD CONSTRAINT l_artist_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_label(id);

ALTER TABLE l_artist_mood_example
   ADD CONSTRAINT l_artist_mood_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_mood(id);

ALTER TABLE l_artist_place_example
   ADD CONSTRAINT l_artist_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_place(id);

ALTER TABLE l_artist_recording_example
   ADD CONSTRAINT l_artist_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_recording(id);

ALTER TABLE l_artist_release_example
   ADD CONSTRAINT l_artist_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_release(id);

ALTER TABLE l_artist_release_group_example
   ADD CONSTRAINT l_artist_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_release_group(id);

ALTER TABLE l_artist_series_example
   ADD CONSTRAINT l_artist_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_series(id);

ALTER TABLE l_artist_url_example
   ADD CONSTRAINT l_artist_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_url(id);

ALTER TABLE l_artist_work_example
   ADD CONSTRAINT l_artist_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_work(id);

ALTER TABLE l_event_event_example
   ADD CONSTRAINT l_event_event_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_event(id);

ALTER TABLE l_event_genre_example
   ADD CONSTRAINT l_event_genre_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_genre(id);

ALTER TABLE l_event_instrument_example
   ADD CONSTRAINT l_event_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_instrument(id);

ALTER TABLE l_event_label_example
   ADD CONSTRAINT l_event_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_label(id);

ALTER TABLE l_event_mood_example
   ADD CONSTRAINT l_event_mood_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_mood(id);

ALTER TABLE l_event_place_example
   ADD CONSTRAINT l_event_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_place(id);

ALTER TABLE l_event_recording_example
   ADD CONSTRAINT l_event_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_recording(id);

ALTER TABLE l_event_release_example
   ADD CONSTRAINT l_event_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_release(id);

ALTER TABLE l_event_release_group_example
   ADD CONSTRAINT l_event_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_release_group(id);

ALTER TABLE l_event_series_example
   ADD CONSTRAINT l_event_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_series(id);

ALTER TABLE l_event_url_example
   ADD CONSTRAINT l_event_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_url(id);

ALTER TABLE l_event_work_example
   ADD CONSTRAINT l_event_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_work(id);

ALTER TABLE l_genre_genre_example
   ADD CONSTRAINT l_genre_genre_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_genre(id);

ALTER TABLE l_genre_instrument_example
   ADD CONSTRAINT l_genre_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_instrument(id);

ALTER TABLE l_genre_label_example
   ADD CONSTRAINT l_genre_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_label(id);

ALTER TABLE l_genre_mood_example
   ADD CONSTRAINT l_genre_mood_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_mood(id);

ALTER TABLE l_genre_place_example
   ADD CONSTRAINT l_genre_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_place(id);

ALTER TABLE l_genre_recording_example
   ADD CONSTRAINT l_genre_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_recording(id);

ALTER TABLE l_genre_release_example
   ADD CONSTRAINT l_genre_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_release(id);

ALTER TABLE l_genre_release_group_example
   ADD CONSTRAINT l_genre_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_release_group(id);

ALTER TABLE l_genre_series_example
   ADD CONSTRAINT l_genre_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_series(id);

ALTER TABLE l_genre_url_example
   ADD CONSTRAINT l_genre_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_url(id);

ALTER TABLE l_genre_work_example
   ADD CONSTRAINT l_genre_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_work(id);

ALTER TABLE l_instrument_instrument_example
   ADD CONSTRAINT l_instrument_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_instrument(id);

ALTER TABLE l_instrument_label_example
   ADD CONSTRAINT l_instrument_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_label(id);

ALTER TABLE l_instrument_mood_example
   ADD CONSTRAINT l_instrument_mood_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_mood(id);

ALTER TABLE l_instrument_place_example
   ADD CONSTRAINT l_instrument_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_place(id);

ALTER TABLE l_instrument_recording_example
   ADD CONSTRAINT l_instrument_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_recording(id);

ALTER TABLE l_instrument_release_example
   ADD CONSTRAINT l_instrument_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_release(id);

ALTER TABLE l_instrument_release_group_example
   ADD CONSTRAINT l_instrument_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_release_group(id);

ALTER TABLE l_instrument_series_example
   ADD CONSTRAINT l_instrument_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_series(id);

ALTER TABLE l_instrument_url_example
   ADD CONSTRAINT l_instrument_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_url(id);

ALTER TABLE l_instrument_work_example
   ADD CONSTRAINT l_instrument_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_work(id);

ALTER TABLE l_label_label_example
   ADD CONSTRAINT l_label_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_label(id);

ALTER TABLE l_label_mood_example
   ADD CONSTRAINT l_label_mood_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_mood(id);

ALTER TABLE l_label_place_example
   ADD CONSTRAINT l_label_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_place(id);

ALTER TABLE l_label_recording_example
   ADD CONSTRAINT l_label_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_recording(id);

ALTER TABLE l_label_release_example
   ADD CONSTRAINT l_label_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_release(id);

ALTER TABLE l_label_release_group_example
   ADD CONSTRAINT l_label_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_release_group(id);

ALTER TABLE l_label_series_example
   ADD CONSTRAINT l_label_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_series(id);

ALTER TABLE l_label_url_example
   ADD CONSTRAINT l_label_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_url(id);

ALTER TABLE l_label_work_example
   ADD CONSTRAINT l_label_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_label_work(id);

ALTER TABLE l_mood_mood_example
   ADD CONSTRAINT l_mood_mood_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_mood_mood(id);

ALTER TABLE l_mood_place_example
   ADD CONSTRAINT l_mood_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_mood_place(id);

ALTER TABLE l_mood_recording_example
   ADD CONSTRAINT l_mood_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_mood_recording(id);

ALTER TABLE l_mood_release_example
   ADD CONSTRAINT l_mood_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_mood_release(id);

ALTER TABLE l_mood_release_group_example
   ADD CONSTRAINT l_mood_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_mood_release_group(id);

ALTER TABLE l_mood_url_example
   ADD CONSTRAINT l_mood_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_mood_url(id);

ALTER TABLE l_mood_work_example
   ADD CONSTRAINT l_mood_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_mood_work(id);

ALTER TABLE l_place_place_example
   ADD CONSTRAINT l_place_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_place(id);

ALTER TABLE l_place_recording_example
   ADD CONSTRAINT l_place_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_recording(id);

ALTER TABLE l_place_release_example
   ADD CONSTRAINT l_place_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_release(id);

ALTER TABLE l_place_release_group_example
   ADD CONSTRAINT l_place_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_release_group(id);

ALTER TABLE l_place_series_example
   ADD CONSTRAINT l_place_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_series(id);

ALTER TABLE l_place_url_example
   ADD CONSTRAINT l_place_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_url(id);

ALTER TABLE l_place_work_example
   ADD CONSTRAINT l_place_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_place_work(id);

ALTER TABLE l_recording_recording_example
   ADD CONSTRAINT l_recording_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_recording_recording(id);

ALTER TABLE l_recording_release_example
   ADD CONSTRAINT l_recording_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_recording_release(id);

ALTER TABLE l_recording_release_group_example
   ADD CONSTRAINT l_recording_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_recording_release_group(id);

ALTER TABLE l_recording_series_example
   ADD CONSTRAINT l_recording_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_recording_series(id);

ALTER TABLE l_recording_url_example
   ADD CONSTRAINT l_recording_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_recording_url(id);

ALTER TABLE l_recording_work_example
   ADD CONSTRAINT l_recording_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_recording_work(id);

ALTER TABLE l_release_group_release_group_example
   ADD CONSTRAINT l_release_group_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_group_release_group(id);

ALTER TABLE l_release_group_series_example
   ADD CONSTRAINT l_release_group_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_group_series(id);

ALTER TABLE l_release_group_url_example
   ADD CONSTRAINT l_release_group_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_group_url(id);

ALTER TABLE l_release_group_work_example
   ADD CONSTRAINT l_release_group_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_group_work(id);

ALTER TABLE l_release_release_example
   ADD CONSTRAINT l_release_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_release(id);

ALTER TABLE l_release_release_group_example
   ADD CONSTRAINT l_release_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_release_group(id);

ALTER TABLE l_release_series_example
   ADD CONSTRAINT l_release_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_series(id);

ALTER TABLE l_release_url_example
   ADD CONSTRAINT l_release_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_url(id);

ALTER TABLE l_release_work_example
   ADD CONSTRAINT l_release_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_release_work(id);

ALTER TABLE l_series_series_example
   ADD CONSTRAINT l_series_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_series_series(id);

ALTER TABLE l_series_url_example
   ADD CONSTRAINT l_series_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_series_url(id);

ALTER TABLE l_series_work_example
   ADD CONSTRAINT l_series_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_series_work(id);

ALTER TABLE l_url_url_example
   ADD CONSTRAINT l_url_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_url_url(id);

ALTER TABLE l_url_work_example
   ADD CONSTRAINT l_url_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_url_work(id);

ALTER TABLE l_work_work_example
   ADD CONSTRAINT l_work_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_work_work(id);

ALTER TABLE link_type_documentation
   ADD CONSTRAINT link_type_documentation_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.link_type(id);

