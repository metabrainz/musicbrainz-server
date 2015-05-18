\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE editor_collection_type -- Already dropped in slave update script
      ADD CONSTRAINT allowed_collection_entity_type CHECK (
          entity_type IN ('area', 'artist', 'event', 'instrument', 'label', 'place', 'recording', 'release', 'release_group', 'series', 'work')
      );

ALTER TABLE editor_collection_area
   ADD CONSTRAINT editor_collection_area_fk_collection
     FOREIGN KEY (collection)
     REFERENCES editor_collection(id),
   ADD CONSTRAINT editor_collection_area_fk_area
     FOREIGN KEY (area)
     REFERENCES area(id);

ALTER TABLE editor_collection_artist
   ADD CONSTRAINT editor_collection_artist_fk_collection
     FOREIGN KEY (collection)
     REFERENCES editor_collection(id),
   ADD CONSTRAINT editor_collection_artist_fk_artist
     FOREIGN KEY (artist)
     REFERENCES artist(id);

ALTER TABLE editor_collection_instrument
   ADD CONSTRAINT editor_collection_instrument_fk_collection
     FOREIGN KEY (collection)
     REFERENCES editor_collection(id),
   ADD CONSTRAINT editor_collection_instrument_fk_instrument
     FOREIGN KEY (instrument)
     REFERENCES instrument(id);

ALTER TABLE editor_collection_label
   ADD CONSTRAINT editor_collection_label_fk_collection
     FOREIGN KEY (collection)
     REFERENCES editor_collection(id),
   ADD CONSTRAINT editor_collection_label_fk_label
     FOREIGN KEY (label)
     REFERENCES label(id);

ALTER TABLE editor_collection_place
   ADD CONSTRAINT editor_collection_place_fk_collection
     FOREIGN KEY (collection)
     REFERENCES editor_collection(id),
   ADD CONSTRAINT editor_collection_place_fk_place
     FOREIGN KEY (place)
     REFERENCES place(id);

ALTER TABLE editor_collection_recording
   ADD CONSTRAINT editor_collection_recording_fk_collection
     FOREIGN KEY (collection)
     REFERENCES editor_collection(id),
   ADD CONSTRAINT editor_collection_recording_fk_recording
     FOREIGN KEY (recording)
     REFERENCES recording(id);

ALTER TABLE editor_collection_release_group
   ADD CONSTRAINT editor_collection_release_group_fk_collection
     FOREIGN KEY (collection)
     REFERENCES editor_collection(id),
   ADD CONSTRAINT editor_collection_release_group_fk_release_group
     FOREIGN KEY (release_group)
     REFERENCES release_group(id);

ALTER TABLE editor_collection_series
   ADD CONSTRAINT editor_collection_series_fk_collection
     FOREIGN KEY (collection)
     REFERENCES editor_collection(id),
   ADD CONSTRAINT editor_collection_series_fk_series
     FOREIGN KEY (series)
     REFERENCES series(id);

ALTER TABLE editor_collection_work
   ADD CONSTRAINT editor_collection_work_fk_collection
     FOREIGN KEY (collection)
     REFERENCES editor_collection(id),
   ADD CONSTRAINT editor_collection_work_fk_work
     FOREIGN KEY (work)
     REFERENCES work(id);

COMMIT;
