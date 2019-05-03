-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = 'event_art_archive';

ALTER TABLE art_type DROP CONSTRAINT IF EXISTS art_type_fk_parent;
ALTER TABLE event_art DROP CONSTRAINT IF EXISTS event_art_fk_event;
ALTER TABLE event_art DROP CONSTRAINT IF EXISTS event_art_fk_edit;
ALTER TABLE event_art DROP CONSTRAINT IF EXISTS event_art_fk_mime_type;
ALTER TABLE event_art_type DROP CONSTRAINT IF EXISTS event_art_type_fk_id;
ALTER TABLE event_art_type DROP CONSTRAINT IF EXISTS event_art_type_fk_type_id;
