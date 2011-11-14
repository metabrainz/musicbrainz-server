BEGIN;

-- Commit f5cd410a93b247ee on the 26th introduced this bug, so all editors who
-- have accepted edits after this date have bad counts.
SELECT DISTINCT editor
INTO TEMPORARY tmp_editors_to_fix
FROM edit
WHERE open_time > '2011-09-26';

UPDATE editor SET auto_edits_accepted = recalculated.edit_count
FROM (
  SELECT fix.editor, COALESCE(edit_count, 0) AS edit_count
  FROM (
    SELECT edit.editor, count(id) AS edit_count
    FROM edit
    JOIN tmp_editors_to_fix fix ON fix.editor = edit.editor
    WHERE edit.status = 2    -- Applied
      AND edit.autoedit = 1  -- (True)
    GROUP BY edit.editor
  ) edit
  RIGHT JOIN tmp_editors_to_fix fix ON fix.editor = edit.editor
) recalculated
WHERE recalculated.editor = editor.id;

UPDATE editor SET edits_accepted = recalculated.edit_count
FROM (
  SELECT fix.editor, COALESCE(edit_count, 0) AS edit_count
  FROM (
    SELECT edit.editor, count(id) AS edit_count
    FROM edit
    JOIN tmp_editors_to_fix fix ON fix.editor = edit.editor
    WHERE edit.status = 2     -- Applied
      AND edit.autoedit != 1  -- (Not true)
    GROUP BY edit.editor
  ) edit
  RIGHT JOIN tmp_editors_to_fix fix ON fix.editor = edit.editor
) recalculated
WHERE recalculated.editor = editor.id;

COMMIT;
