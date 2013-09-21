\set ON_ERROR_STOP 1
BEGIN;

-----------------------
-- CREATE NEW COLUMN --
-----------------------

ALTER TABLE area ADD COLUMN comment VARCHAR(255) NOT NULL DEFAULT '';

--------------------
-- CREATE INDEXES --
--------------------

CREATE UNIQUE INDEX area_idx_null_comment ON area (name) WHERE comment IS NULL;
CREATE UNIQUE INDEX area_idx_uniq_name_comment ON area (name, comment) WHERE comment IS NOT NULL;

COMMIT;
