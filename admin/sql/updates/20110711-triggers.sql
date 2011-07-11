BEGIN;

CREATE TRIGGER "reptg_url_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "url_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_work_alias"
AFTER INSERT OR DELETE OR UPDATE ON "work_alias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

COMMIT;
