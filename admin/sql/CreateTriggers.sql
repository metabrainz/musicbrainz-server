\set ON_ERROR_STOP 1

create trigger a_ins_album after insert on album 
               for each row execute procedure insert_album_meta();

create trigger a_del_album after delete on album 
               for each row execute procedure delete_album_meta();

CREATE TRIGGER a_ins_albumjoin AFTER INSERT ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE a_ins_albumjoin();
CREATE TRIGGER a_upd_albumjoin AFTER UPDATE ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE a_upd_albumjoin();
CREATE TRIGGER a_del_albumjoin AFTER DELETE ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE a_del_albumjoin();

CREATE TRIGGER a_ins_discid AFTER INSERT ON discid
    FOR EACH ROW EXECUTE PROCEDURE a_ins_discid();
CREATE TRIGGER a_upd_discid AFTER UPDATE ON discid
    FOR EACH ROW EXECUTE PROCEDURE a_upd_discid();
CREATE TRIGGER a_del_discid AFTER DELETE ON discid
    FOR EACH ROW EXECUTE PROCEDURE a_del_discid();

CREATE TRIGGER a_ins_trmjoin AFTER INSERT ON trmjoin
    FOR EACH ROW EXECUTE PROCEDURE a_ins_trmjoin();
CREATE TRIGGER a_upd_trmjoin AFTER UPDATE ON trmjoin
    FOR EACH ROW EXECUTE PROCEDURE a_upd_trmjoin();
CREATE TRIGGER a_del_trmjoin AFTER DELETE ON trmjoin
    FOR EACH ROW EXECUTE PROCEDURE a_del_trmjoin();

create trigger b_upd_moderation before update on moderation 
               for each row execute procedure before_update_moderation();

-- vi: set ts=4 sw=4 et :
