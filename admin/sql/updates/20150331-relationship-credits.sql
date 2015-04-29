\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE l_area_area ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_area_area ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_area_artist ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_area_artist ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_area_event ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_area_event ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_area_instrument ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_area_instrument ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_area_label ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_area_label ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_area_place ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_area_place ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_area_recording ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_area_recording ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_area_release ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_area_release ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_area_release_group ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_area_release_group ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_area_series ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_area_series ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_area_url ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_area_url ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_area_work ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_area_work ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_artist_artist ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_artist_artist ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_artist_event ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_artist_event ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_artist_instrument ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_artist_instrument ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_artist_label ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_artist_label ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_artist_place ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_artist_place ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_artist_recording ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_artist_recording ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_artist_release ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_artist_release ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_artist_release_group ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_artist_release_group ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_artist_series ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_artist_series ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_artist_url ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_artist_url ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_artist_work ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_artist_work ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_event_event ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_event_event ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_event_instrument ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_event_instrument ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_event_label ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_event_label ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_event_place ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_event_place ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_event_recording ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_event_recording ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_event_release ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_event_release ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_event_release_group ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_event_release_group ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_event_series ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_event_series ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_event_url ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_event_url ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_event_work ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_event_work ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_label_label ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_label_label ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_instrument_instrument ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_instrument_instrument ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_instrument_label ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_instrument_label ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_instrument_place ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_instrument_place ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_instrument_recording ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_instrument_recording ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_instrument_release ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_instrument_release ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_instrument_release_group ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_instrument_release_group ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_instrument_series ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_instrument_series ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_instrument_url ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_instrument_url ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_instrument_work ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_instrument_work ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_label_place ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_label_place ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_label_recording ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_label_recording ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_label_release ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_label_release ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_label_release_group ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_label_release_group ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_label_series ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_label_series ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_label_url ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_label_url ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_label_work ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_label_work ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_place_place ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_place_place ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_place_recording ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_place_recording ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_place_release ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_place_release ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_place_release_group ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_place_release_group ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_place_series ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_place_series ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_place_url ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_place_url ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_place_work ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_place_work ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_recording_recording ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_recording_recording ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_recording_release ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_recording_release ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_recording_release_group ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_recording_release_group ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_recording_series ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_recording_series ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_recording_url ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_recording_url ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_recording_work ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_recording_work ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_release_release ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_release_release ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_release_release_group ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_release_release_group ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_release_series ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_release_series ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_release_url ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_release_url ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_release_work ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_release_work ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_release_group_release_group ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_release_group_release_group ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_release_group_series ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_release_group_series ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_release_group_url ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_release_group_url ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_release_group_work ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_release_group_work ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_series_series ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_series_series ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_series_url ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_series_url ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_series_work ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_series_work ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_url_url ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_url_url ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_url_work ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_url_work ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

ALTER TABLE l_work_work ADD COLUMN entity0_credit TEXT NOT NULL DEFAULT '';
ALTER TABLE l_work_work ADD COLUMN entity1_credit TEXT NOT NULL DEFAULT '';

COMMIT;
