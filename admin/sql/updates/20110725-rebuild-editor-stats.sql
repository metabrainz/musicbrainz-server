BEGIN;

UPDATE editor SET edits_failed = s.failed
FROM (
    SELECT editor, count(id) AS failed
    FROM edit
    WHERE status NOT IN (4, 5, 6, 7) -- FAILEDDEP, ERROR, FAILEDPREREQ, NOVOTES
    GROUP BY editor
) s
WHERE editor.id = s.editor;

COMMIT;
