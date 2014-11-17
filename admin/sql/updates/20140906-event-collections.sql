\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE editor_collection_event
(
    collection          INTEGER NOT NULL, -- PK, references editor_collection.id
    event               INTEGER NOT NULL -- PK, references event.id
);

ALTER TABLE editor_collection_event ADD CONSTRAINT editor_collection_event_pkey PRIMARY KEY (collection, event);

INSERT INTO editor_collection_type (id, name, entity_type, parent, child_order) VALUES
        (4, 'Event', 'event', NULL, 2),
	(5, 'Attending', 'event', 4, 1),
	(6, 'Maybe attending', 'event', 4, 2);

COMMIT;
