\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE l_area_area                   DROP CONSTRAINT IF EXISTS non_loop_relationship;
ALTER TABLE l_artist_artist               DROP CONSTRAINT IF EXISTS non_loop_relationship;
ALTER TABLE l_event_event                 DROP CONSTRAINT IF EXISTS non_loop_relationship;
ALTER TABLE l_label_label                 DROP CONSTRAINT IF EXISTS non_loop_relationship;
ALTER TABLE l_instrument_instrument       DROP CONSTRAINT IF EXISTS non_loop_relationship;
ALTER TABLE l_place_place                 DROP CONSTRAINT IF EXISTS non_loop_relationship;
ALTER TABLE l_recording_recording         DROP CONSTRAINT IF EXISTS non_loop_relationship;
ALTER TABLE l_release_release             DROP CONSTRAINT IF EXISTS non_loop_relationship;
ALTER TABLE l_release_group_release_group DROP CONSTRAINT IF EXISTS non_loop_relationship;
ALTER TABLE l_series_series               DROP CONSTRAINT IF EXISTS non_loop_relationship;
ALTER TABLE l_url_url                     DROP CONSTRAINT IF EXISTS non_loop_relationship;
ALTER TABLE l_work_work                   DROP CONSTRAINT IF EXISTS non_loop_relationship;

ALTER TABLE l_area_area                   ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_artist_artist               ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_event_event                 ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_label_label                 ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_instrument_instrument       ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_place_place                 ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_recording_recording         ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_release_release             ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_release_group_release_group ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_series_series               ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_url_url                     ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);
ALTER TABLE l_work_work                   ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

COMMIT;
