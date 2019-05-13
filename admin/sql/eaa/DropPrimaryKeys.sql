-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = 'event_art_archive';

ALTER TABLE art_type DROP CONSTRAINT IF EXISTS art_type_pkey;
ALTER TABLE event_art DROP CONSTRAINT IF EXISTS event_art_pkey;
ALTER TABLE event_art_type DROP CONSTRAINT IF EXISTS event_art_type_pkey;
