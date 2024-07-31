\set ON_ERROR_STOP 1

BEGIN;
SET LOCAL statement_timeout = 0;

UPDATE editor
   SET privs = privs | 8192 -- set new beginner flag
 WHERE id != 4 -- avoid setting ModBot as beginner
   AND NOT deleted
   AND ( 
        member_since > NOW() - INTERVAL '2 weeks'
       OR
        NOT EXISTS (
          SELECT 1
            FROM edit
           WHERE edit.editor = editor.id
             AND edit.autoedit = 0
             AND edit.status = 2
          OFFSET 9
        )
   );

COMMIT;
