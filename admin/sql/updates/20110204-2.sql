BEGIN;

CREATE TRIGGER "reptg_echoprint"
AFTER INSERT OR DELETE OR UPDATE ON "echoprint"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_recording_echoprint"
AFTER INSERT OR DELETE OR UPDATE ON "recording_echoprint"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

COMMIT;
