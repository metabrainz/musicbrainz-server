-- Abstract: add replication triggers for the language/script tables

\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER "reptg_language" 
AFTER INSERT OR DELETE OR UPDATE ON "language"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_script" 
AFTER INSERT OR DELETE OR UPDATE ON "script"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_script_language" 
AFTER INSERT OR DELETE OR UPDATE ON "script_language"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

COMMIT;

-- vi: set ts=4 sw=4 et :
