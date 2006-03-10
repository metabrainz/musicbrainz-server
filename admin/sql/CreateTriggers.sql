\set ON_ERROR_STOP 1

-- These XXXX_album_meta() functions should really have the _meta dropped
CREATE TRIGGER a_ins_album AFTER INSERT ON album 
    FOR EACH ROW EXECUTE PROCEDURE insert_album_meta();
CREATE TRIGGER a_upd_album after update on album 
    FOR EACH ROW EXECUTE PROCEDURE update_album_meta();
CREATE TRIGGER a_del_album after DELETE ON album 
    FOR EACH ROW EXECUTE PROCEDURE delete_album_meta();

CREATE TRIGGER a_ins_albumjoin AFTER INSERT ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE a_ins_albumjoin();
CREATE TRIGGER a_upd_albumjoin AFTER UPDATE ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE a_upd_albumjoin();
CREATE TRIGGER a_del_albumjoin AFTER DELETE ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE a_del_albumjoin();

CREATE TRIGGER a_ins_album_cdtoc AFTER INSERT ON album_cdtoc
    FOR EACH ROW EXECUTE PROCEDURE a_ins_album_cdtoc();
CREATE TRIGGER a_upd_album_cdtoc AFTER UPDATE ON album_cdtoc
    FOR EACH ROW EXECUTE PROCEDURE a_upd_album_cdtoc();
CREATE TRIGGER a_del_album_cdtoc AFTER DELETE ON album_cdtoc
    FOR EACH ROW EXECUTE PROCEDURE a_del_album_cdtoc();

CREATE TRIGGER a_ins_trmjoin AFTER INSERT ON trmjoin
    FOR EACH ROW EXECUTE PROCEDURE a_ins_trmjoin();
CREATE TRIGGER a_del_trmjoin AFTER DELETE ON trmjoin
    FOR EACH ROW EXECUTE PROCEDURE a_del_trmjoin();

CREATE TRIGGER a_idu_trm_stat AFTER INSERT OR DELETE OR UPDATE ON trm_stat
    FOR EACH ROW EXECUTE PROCEDURE a_idu_trm_stat();
CREATE TRIGGER a_idu_trmjoin_stat AFTER INSERT OR DELETE OR UPDATE ON trmjoin_stat
    FOR EACH ROW EXECUTE PROCEDURE a_idu_trmjoin_stat();

CREATE TRIGGER a_upd_moderation_open AFTER UPDATE ON moderation_open
    FOR EACH ROW EXECUTE PROCEDURE after_update_moderation_open();

CREATE TRIGGER b_iu_release BEFORE INSERT OR UPDATE ON release
    FOR EACH ROW EXECUTE PROCEDURE before_insertupdate_release();
CREATE TRIGGER a_ins_release AFTER INSERT ON release
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release();
CREATE TRIGGER a_upd_release AFTER UPDATE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release();
CREATE TRIGGER a_del_release AFTER DELETE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_del_release();

CREATE TRIGGER a_ins_album_amazon_asin AFTER INSERT ON album_amazon_asin
    FOR EACH ROW EXECUTE PROCEDURE a_ins_album_amazon_asin();
CREATE TRIGGER a_upd_album_amazon_asin AFTER UPDATE ON album_amazon_asin
    FOR EACH ROW EXECUTE PROCEDURE a_upd_album_amazon_asin();
CREATE TRIGGER a_del_album_amazon_asin AFTER DELETE ON album_amazon_asin
    FOR EACH ROW EXECUTE PROCEDURE a_del_album_amazon_asin();

CREATE TRIGGER a_ins_puidjoin AFTER INSERT ON puidjoin
    FOR EACH ROW EXECUTE PROCEDURE a_ins_puidjoin();
CREATE TRIGGER a_del_puidjoin AFTER DELETE ON puidjoin
    FOR EACH ROW EXECUTE PROCEDURE a_del_puidjoin();

CREATE TRIGGER a_idu_puid_stat AFTER INSERT OR DELETE OR UPDATE ON puid_stat
    FOR EACH ROW EXECUTE PROCEDURE a_idu_puid_stat();
CREATE TRIGGER a_idu_puidjoin_stat AFTER INSERT OR DELETE OR UPDATE ON puidjoin_stat
    FOR EACH ROW EXECUTE PROCEDURE a_idu_puidjoin_stat();

-- vi: set ts=4 sw=4 et :
