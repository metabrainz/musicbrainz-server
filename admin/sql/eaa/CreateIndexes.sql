\set ON_ERROR_STOP 1

BEGIN;

SET search_path = 'event_art_archive';

CREATE INDEX event_art_idx_event ON event_art (event);
CREATE UNIQUE INDEX art_type_idx_gid ON art_type (gid);

COMMIT;
