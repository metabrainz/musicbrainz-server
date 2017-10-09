-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = json_dump, public;

ALTER TABLE area_json ADD CONSTRAINT area_json_pkey PRIMARY KEY (id, replication_sequence);
ALTER TABLE artist_json ADD CONSTRAINT artist_json_pkey PRIMARY KEY (id, replication_sequence);
ALTER TABLE deleted_entities ADD CONSTRAINT deleted_entities_pkey PRIMARY KEY (entity_type, id);
ALTER TABLE event_json ADD CONSTRAINT event_json_pkey PRIMARY KEY (id, replication_sequence);
ALTER TABLE instrument_json ADD CONSTRAINT instrument_json_pkey PRIMARY KEY (id, replication_sequence);
ALTER TABLE label_json ADD CONSTRAINT label_json_pkey PRIMARY KEY (id, replication_sequence);
ALTER TABLE place_json ADD CONSTRAINT place_json_pkey PRIMARY KEY (id, replication_sequence);
ALTER TABLE recording_json ADD CONSTRAINT recording_json_pkey PRIMARY KEY (id, replication_sequence);
ALTER TABLE release_group_json ADD CONSTRAINT release_group_json_pkey PRIMARY KEY (id, replication_sequence);
ALTER TABLE release_json ADD CONSTRAINT release_json_pkey PRIMARY KEY (id, replication_sequence);
ALTER TABLE series_json ADD CONSTRAINT series_json_pkey PRIMARY KEY (id, replication_sequence);
ALTER TABLE work_json ADD CONSTRAINT work_json_pkey PRIMARY KEY (id, replication_sequence);
