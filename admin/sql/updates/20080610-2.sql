\set ON_ERROR_STOP 1

BEGIN;

-- IMPORTANT: This script should only be run on non-SLAVE servers

-- Create function to keep lastupdate columns up to date
create or replace function b_iu_update_lastmodified () returns TRIGGER as '
begin
   NEW.lastupdate = now();
   return NEW;
end;
' language 'plpgsql';

-- Create triggers
create trigger b_iu_artist BEFORE INSERT OR DELETE OR UPDATE ON artist 
   FOR EACH ROW EXECUTE PROCEDURE b_iu_update_lastmodified();
create trigger b_iu_album BEFORE INSERT OR DELETE OR UPDATE ON album 
   FOR EACH ROW EXECUTE PROCEDURE b_iu_update_lastmodified();
create trigger b_iu_label BEFORE INSERT OR DELETE OR UPDATE ON label 
   FOR EACH ROW EXECUTE PROCEDURE b_iu_update_lastmodified();
create trigger b_iu_track BEFORE INSERT OR DELETE OR UPDATE ON track 
   FOR EACH ROW EXECUTE PROCEDURE b_iu_update_lastmodified();

COMMIT;
