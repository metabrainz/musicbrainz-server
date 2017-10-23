\set ON_ERROR_STOP 1

BEGIN;

SET search_path = json_dump;

CREATE UNIQUE INDEX tmp_checked_entities_idx_uniq ON tmp_checked_entities (id, entity_type);

CREATE INDEX deleted_entities_idx_replication_sequence ON deleted_entities (replication_sequence);

COMMIT;
