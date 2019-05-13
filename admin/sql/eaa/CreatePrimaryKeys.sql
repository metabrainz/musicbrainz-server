-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'event_art_archive';

ALTER TABLE art_type ADD CONSTRAINT art_type_pkey PRIMARY KEY (id);
ALTER TABLE event_art ADD CONSTRAINT event_art_pkey PRIMARY KEY (id);
ALTER TABLE event_art_type ADD CONSTRAINT event_art_type_pkey PRIMARY KEY (id, type_id);
