\set ON_ERROR_STOP 1

BEGIN;

UPDATE editor
   SET privs = privs | 16384 -- set new voting disabled flag
 WHERE (privs & 1024) > 0; -- where editor had editing disabled flag

COMMIT;
