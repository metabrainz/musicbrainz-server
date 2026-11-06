\set ON_ERROR_STOP 1

BEGIN;

DO $$
BEGIN
  PERFORM 1 FROM pg_index
  WHERE indexrelid = to_regclass('musicbrainz.vote_idx_editor_edit')
  AND indisunique;

  IF NOT FOUND THEN
    UPDATE vote v1
    SET superseded = TRUE
    WHERE NOT v1.superseded
    AND EXISTS (
      SELECT 1
      FROM vote v2
      WHERE v2.editor = v1.editor
      AND v2.edit = v1.edit
      AND NOT v2.superseded
      -- `vote_time` is nullable, hence the coalesce.
      -- Also, as noted in admin/sql/updates/20160507-mbs-8727.sql, there
      -- were previously some cases where the votes with a later `vote_time`
      -- had a smaller ID. So IDs are only compared if the `vote_time`s are
      -- equal.
      AND (COALESCE(v2.vote_time, '-infinity'), v2.id) >
          (COALESCE(v1.vote_time, '-infinity'), v1.id)
    );

    DROP INDEX IF EXISTS vote_idx_editor_edit;
    CREATE UNIQUE INDEX vote_idx_editor_edit ON vote (editor, edit) WHERE superseded = FALSE;
  END IF;
END
$$;

COMMIT;
