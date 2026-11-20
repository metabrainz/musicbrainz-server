\set ON_ERROR_STOP 1

BEGIN;

CREATE INDEX release_group_tag_idx_tag_count
    ON release_group_tag (tag, count, release_group)
    WHERE count > 0;

COMMIT;
