CREATE UNIQUE INDEX CONCURRENTLY medium_idx_uniq ON medium (release, position);

DROP INDEX IF EXISTS medium_idx_release;
