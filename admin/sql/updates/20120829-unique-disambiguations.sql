CREATE UNIQUE INDEX CONCURRENTLY artist_idx_null_comment
ON artist (name) WHERE comment IS NULL;

CREATE UNIQUE INDEX CONCURRENTLY artist_idx_uniq_name_comment
ON artist (name, comment) WHERE comment IS NOT NULL;

CREATE UNIQUE INDEX CONCURRENTLY label_idx_null_comment
ON label (name) WHERE comment IS NULL;

CREATE UNIQUE INDEX CONCURRENTLY label_idx_uniq_name_comment
ON label (name, comment) WHERE comment IS NOT NULL;
