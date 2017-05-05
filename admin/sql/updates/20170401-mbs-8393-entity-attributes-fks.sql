\set ON_ERROR_STOP 1
BEGIN;

-----------------------------------------------------------------------
-- add foreign key constraints
-----------------------------------------------------------------------

ALTER TABLE area_attribute
   ADD CONSTRAINT area_attribute_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE area_attribute
   ADD CONSTRAINT area_attribute_fk_area_attribute_type
   FOREIGN KEY (area_attribute_type)
   REFERENCES area_attribute_type(id);

ALTER TABLE area_attribute
   ADD CONSTRAINT area_attribute_fk_area_attribute_type_allowed_value
   FOREIGN KEY (area_attribute_type_allowed_value)
   REFERENCES area_attribute_type_allowed_value(id);

ALTER TABLE area_attribute_type
   ADD CONSTRAINT area_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES area_attribute_type(id);

ALTER TABLE area_attribute_type_allowed_value
   ADD CONSTRAINT area_attribute_type_allowed_value_fk_area_attribute_type
   FOREIGN KEY (area_attribute_type)
   REFERENCES area_attribute_type(id);

ALTER TABLE area_attribute_type_allowed_value
   ADD CONSTRAINT area_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES area_attribute_type_allowed_value(id);

ALTER TABLE artist_attribute
   ADD CONSTRAINT artist_attribute_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE artist_attribute
   ADD CONSTRAINT artist_attribute_fk_artist_attribute_type
   FOREIGN KEY (artist_attribute_type)
   REFERENCES artist_attribute_type(id);

ALTER TABLE artist_attribute
   ADD CONSTRAINT artist_attribute_fk_artist_attribute_type_allowed_value
   FOREIGN KEY (artist_attribute_type_allowed_value)
   REFERENCES artist_attribute_type_allowed_value(id);

ALTER TABLE artist_attribute_type
   ADD CONSTRAINT artist_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES artist_attribute_type(id);

ALTER TABLE artist_attribute_type_allowed_value
   ADD CONSTRAINT artist_attribute_type_allowed_value_fk_artist_attribute_type
   FOREIGN KEY (artist_attribute_type)
   REFERENCES artist_attribute_type(id);

ALTER TABLE artist_attribute_type_allowed_value
   ADD CONSTRAINT artist_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES artist_attribute_type_allowed_value(id);

ALTER TABLE event_attribute
   ADD CONSTRAINT event_attribute_fk_event
   FOREIGN KEY (event)
   REFERENCES event(id);

ALTER TABLE event_attribute
   ADD CONSTRAINT event_attribute_fk_event_attribute_type
   FOREIGN KEY (event_attribute_type)
   REFERENCES event_attribute_type(id);

ALTER TABLE event_attribute
   ADD CONSTRAINT event_attribute_fk_event_attribute_type_allowed_value
   FOREIGN KEY (event_attribute_type_allowed_value)
   REFERENCES event_attribute_type_allowed_value(id);

ALTER TABLE event_attribute_type
   ADD CONSTRAINT event_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES event_attribute_type(id);

ALTER TABLE event_attribute_type_allowed_value
   ADD CONSTRAINT event_attribute_type_allowed_value_fk_event_attribute_type
   FOREIGN KEY (event_attribute_type)
   REFERENCES event_attribute_type(id);

ALTER TABLE event_attribute_type_allowed_value
   ADD CONSTRAINT event_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES event_attribute_type_allowed_value(id);

ALTER TABLE instrument_attribute
   ADD CONSTRAINT instrument_attribute_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id);

ALTER TABLE instrument_attribute
   ADD CONSTRAINT instrument_attribute_fk_instrument_attribute_type
   FOREIGN KEY (instrument_attribute_type)
   REFERENCES instrument_attribute_type(id);

ALTER TABLE instrument_attribute
   ADD CONSTRAINT instrument_attribute_fk_instrument_attribute_type_allowed_value
   FOREIGN KEY (instrument_attribute_type_allowed_value)
   REFERENCES instrument_attribute_type_allowed_value(id);

ALTER TABLE instrument_attribute_type
   ADD CONSTRAINT instrument_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES instrument_attribute_type(id);

ALTER TABLE instrument_attribute_type_allowed_value
   ADD CONSTRAINT instrument_attribute_type_allowed_value_fk_instrument_attribute_type
   FOREIGN KEY (instrument_attribute_type)
   REFERENCES instrument_attribute_type(id);

ALTER TABLE instrument_attribute_type_allowed_value
   ADD CONSTRAINT instrument_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES instrument_attribute_type_allowed_value(id);

ALTER TABLE label_attribute
   ADD CONSTRAINT label_attribute_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_attribute
   ADD CONSTRAINT label_attribute_fk_label_attribute_type
   FOREIGN KEY (label_attribute_type)
   REFERENCES label_attribute_type(id);

ALTER TABLE label_attribute
   ADD CONSTRAINT label_attribute_fk_label_attribute_type_allowed_value
   FOREIGN KEY (label_attribute_type_allowed_value)
   REFERENCES label_attribute_type_allowed_value(id);

ALTER TABLE label_attribute_type
   ADD CONSTRAINT label_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES label_attribute_type(id);

ALTER TABLE label_attribute_type_allowed_value
   ADD CONSTRAINT label_attribute_type_allowed_value_fk_label_attribute_type
   FOREIGN KEY (label_attribute_type)
   REFERENCES label_attribute_type(id);

ALTER TABLE label_attribute_type_allowed_value
   ADD CONSTRAINT label_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES label_attribute_type_allowed_value(id);

ALTER TABLE medium_attribute
   ADD CONSTRAINT medium_attribute_fk_medium
   FOREIGN KEY (medium)
   REFERENCES medium(id);

ALTER TABLE medium_attribute
   ADD CONSTRAINT medium_attribute_fk_medium_attribute_type
   FOREIGN KEY (medium_attribute_type)
   REFERENCES medium_attribute_type(id);

ALTER TABLE medium_attribute
   ADD CONSTRAINT medium_attribute_fk_medium_attribute_type_allowed_value
   FOREIGN KEY (medium_attribute_type_allowed_value)
   REFERENCES medium_attribute_type_allowed_value(id);

ALTER TABLE medium_attribute_type
   ADD CONSTRAINT medium_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES medium_attribute_type(id);

ALTER TABLE medium_attribute_type_allowed_format
   ADD CONSTRAINT medium_attribute_type_allowed_format_fk_medium_attribute_type
   FOREIGN KEY (medium_attribute_type)
   REFERENCES medium_attribute_type(id);

ALTER TABLE medium_attribute_type_allowed_format
   ADD CONSTRAINT medium_attribute_type_allowed_format_fk_medium_format
   FOREIGN KEY (medium_format)
   REFERENCES medium_format(id);

ALTER TABLE medium_attribute_type_allowed_value
   ADD CONSTRAINT medium_attribute_type_allowed_value_fk_medium_attribute_type
   FOREIGN KEY (medium_attribute_type)
   REFERENCES medium_attribute_type(id);

ALTER TABLE medium_attribute_type_allowed_value
   ADD CONSTRAINT medium_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES medium_attribute_type_allowed_value(id);

ALTER TABLE medium_attribute_type_allowed_value_allowed_format
   ADD CONSTRAINT medium_attribute_type_allowed_value_allowed_format_fk_medium_attribute_type_allowed_value
   FOREIGN KEY (medium_attribute_type_allowed_value)
   REFERENCES medium_attribute_type_allowed_value(id);

ALTER TABLE medium_attribute_type_allowed_value_allowed_format
   ADD CONSTRAINT medium_attribute_type_allowed_value_allowed_format_fk_medium_format
   FOREIGN KEY (medium_format)
   REFERENCES medium_format(id);

ALTER TABLE place_attribute
   ADD CONSTRAINT place_attribute_fk_place
   FOREIGN KEY (place)
   REFERENCES place(id);

ALTER TABLE place_attribute
   ADD CONSTRAINT place_attribute_fk_place_attribute_type
   FOREIGN KEY (place_attribute_type)
   REFERENCES place_attribute_type(id);

ALTER TABLE place_attribute
   ADD CONSTRAINT place_attribute_fk_place_attribute_type_allowed_value
   FOREIGN KEY (place_attribute_type_allowed_value)
   REFERENCES place_attribute_type_allowed_value(id);

ALTER TABLE place_attribute_type
   ADD CONSTRAINT place_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES place_attribute_type(id);

ALTER TABLE place_attribute_type_allowed_value
   ADD CONSTRAINT place_attribute_type_allowed_value_fk_place_attribute_type
   FOREIGN KEY (place_attribute_type)
   REFERENCES place_attribute_type(id);

ALTER TABLE place_attribute_type_allowed_value
   ADD CONSTRAINT place_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES place_attribute_type_allowed_value(id);

ALTER TABLE recording_attribute
   ADD CONSTRAINT recording_attribute_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE recording_attribute
   ADD CONSTRAINT recording_attribute_fk_recording_attribute_type
   FOREIGN KEY (recording_attribute_type)
   REFERENCES recording_attribute_type(id);

ALTER TABLE recording_attribute
   ADD CONSTRAINT recording_attribute_fk_recording_attribute_type_allowed_value
   FOREIGN KEY (recording_attribute_type_allowed_value)
   REFERENCES recording_attribute_type_allowed_value(id);

ALTER TABLE recording_attribute_type
   ADD CONSTRAINT recording_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES recording_attribute_type(id);

ALTER TABLE recording_attribute_type_allowed_value
   ADD CONSTRAINT recording_attribute_type_allowed_value_fk_recording_attribute_type
   FOREIGN KEY (recording_attribute_type)
   REFERENCES recording_attribute_type(id);

ALTER TABLE recording_attribute_type_allowed_value
   ADD CONSTRAINT recording_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES recording_attribute_type_allowed_value(id);

ALTER TABLE release_attribute
   ADD CONSTRAINT release_attribute_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE release_attribute
   ADD CONSTRAINT release_attribute_fk_release_attribute_type
   FOREIGN KEY (release_attribute_type)
   REFERENCES release_attribute_type(id);

ALTER TABLE release_attribute
   ADD CONSTRAINT release_attribute_fk_release_attribute_type_allowed_value
   FOREIGN KEY (release_attribute_type_allowed_value)
   REFERENCES release_attribute_type_allowed_value(id);

ALTER TABLE release_attribute_type
   ADD CONSTRAINT release_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_attribute_type(id);

ALTER TABLE release_attribute_type_allowed_value
   ADD CONSTRAINT release_attribute_type_allowed_value_fk_release_attribute_type
   FOREIGN KEY (release_attribute_type)
   REFERENCES release_attribute_type(id);

ALTER TABLE release_attribute_type_allowed_value
   ADD CONSTRAINT release_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_attribute_type_allowed_value(id);

ALTER TABLE release_group_attribute
   ADD CONSTRAINT release_group_attribute_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_attribute
   ADD CONSTRAINT release_group_attribute_fk_release_group_attribute_type
   FOREIGN KEY (release_group_attribute_type)
   REFERENCES release_group_attribute_type(id);

ALTER TABLE release_group_attribute
   ADD CONSTRAINT release_group_attribute_fk_release_group_attribute_type_allowed_value
   FOREIGN KEY (release_group_attribute_type_allowed_value)
   REFERENCES release_group_attribute_type_allowed_value(id);

ALTER TABLE release_group_attribute_type
   ADD CONSTRAINT release_group_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_group_attribute_type(id);

ALTER TABLE release_group_attribute_type_allowed_value
   ADD CONSTRAINT release_group_attribute_type_allowed_value_fk_release_group_attribute_type
   FOREIGN KEY (release_group_attribute_type)
   REFERENCES release_group_attribute_type(id);

ALTER TABLE release_group_attribute_type_allowed_value
   ADD CONSTRAINT release_group_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_group_attribute_type_allowed_value(id);

ALTER TABLE series_attribute
   ADD CONSTRAINT series_attribute_fk_series
   FOREIGN KEY (series)
   REFERENCES series(id);

ALTER TABLE series_attribute
   ADD CONSTRAINT series_attribute_fk_series_attribute_type
   FOREIGN KEY (series_attribute_type)
   REFERENCES series_attribute_type(id);

ALTER TABLE series_attribute
   ADD CONSTRAINT series_attribute_fk_series_attribute_type_allowed_value
   FOREIGN KEY (series_attribute_type_allowed_value)
   REFERENCES series_attribute_type_allowed_value(id);

ALTER TABLE series_attribute_type
   ADD CONSTRAINT series_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES series_attribute_type(id);

ALTER TABLE series_attribute_type_allowed_value
   ADD CONSTRAINT series_attribute_type_allowed_value_fk_series_attribute_type
   FOREIGN KEY (series_attribute_type)
   REFERENCES series_attribute_type(id);

ALTER TABLE series_attribute_type_allowed_value
   ADD CONSTRAINT series_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES series_attribute_type_allowed_value(id);

-----------------------------------------------------------------------
-- create triggers
-- ensure attribute type allows free text if free text is added
-----------------------------------------------------------------------

CREATE TRIGGER ensure_area_attribute_type_allows_text BEFORE INSERT OR UPDATE ON area_attribute
    FOR EACH ROW EXECUTE PROCEDURE ensure_area_attribute_type_allows_text();

CREATE TRIGGER ensure_artist_attribute_type_allows_text BEFORE INSERT OR UPDATE ON artist_attribute
    FOR EACH ROW EXECUTE PROCEDURE ensure_artist_attribute_type_allows_text();

CREATE TRIGGER ensure_event_attribute_type_allows_text BEFORE INSERT OR UPDATE ON event_attribute
    FOR EACH ROW EXECUTE PROCEDURE ensure_event_attribute_type_allows_text();

CREATE TRIGGER ensure_instrument_attribute_type_allows_text BEFORE INSERT OR UPDATE ON instrument_attribute
    FOR EACH ROW EXECUTE PROCEDURE ensure_instrument_attribute_type_allows_text();

CREATE TRIGGER ensure_label_attribute_type_allows_text BEFORE INSERT OR UPDATE ON label_attribute
    FOR EACH ROW EXECUTE PROCEDURE ensure_label_attribute_type_allows_text();

CREATE TRIGGER ensure_medium_attribute_type_allows_text BEFORE INSERT OR UPDATE ON medium_attribute
    FOR EACH ROW EXECUTE PROCEDURE ensure_medium_attribute_type_allows_text();

CREATE TRIGGER ensure_place_attribute_type_allows_text BEFORE INSERT OR UPDATE ON place_attribute
    FOR EACH ROW EXECUTE PROCEDURE ensure_place_attribute_type_allows_text();

CREATE TRIGGER ensure_recording_attribute_type_allows_text BEFORE INSERT OR UPDATE ON recording_attribute
    FOR EACH ROW EXECUTE PROCEDURE ensure_recording_attribute_type_allows_text();

CREATE TRIGGER ensure_release_attribute_type_allows_text BEFORE INSERT OR UPDATE ON release_attribute
    FOR EACH ROW EXECUTE PROCEDURE ensure_release_attribute_type_allows_text();

CREATE TRIGGER ensure_release_group_attribute_type_allows_text BEFORE INSERT OR UPDATE ON release_group_attribute
    FOR EACH ROW EXECUTE PROCEDURE ensure_release_group_attribute_type_allows_text();

CREATE TRIGGER ensure_series_attribute_type_allows_text BEFORE INSERT OR UPDATE ON series_attribute
    FOR EACH ROW EXECUTE PROCEDURE ensure_series_attribute_type_allows_text();

COMMIT;
