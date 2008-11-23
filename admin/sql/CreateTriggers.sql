\set ON_ERROR_STOP 1

-- Album related tables

    -- These XXXX_album_meta() functions should really have the _meta dropped
CREATE TRIGGER a_ins_album AFTER INSERT ON album 
    FOR EACH ROW EXECUTE PROCEDURE insert_album_meta();
CREATE TRIGGER a_upd_album after update on album 
    FOR EACH ROW EXECUTE PROCEDURE update_album_meta();
CREATE TRIGGER b_del_album BEFORE DELETE ON album 
    FOR EACH ROW EXECUTE PROCEDURE b_del_entity();

CREATE TRIGGER a_ins_albumjoin AFTER INSERT ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE a_ins_albumjoin();
CREATE TRIGGER a_upd_albumjoin AFTER UPDATE ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE a_upd_albumjoin();
CREATE TRIGGER a_del_albumjoin AFTER DELETE ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE a_del_albumjoin();
CREATE TRIGGER b_del_albumjoin BEFORE DELETE ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE b_del_albumjoin();

CREATE TRIGGER a_ins_album_cdtoc AFTER INSERT ON album_cdtoc
    FOR EACH ROW EXECUTE PROCEDURE a_ins_album_cdtoc();
CREATE TRIGGER a_upd_album_cdtoc AFTER UPDATE ON album_cdtoc
    FOR EACH ROW EXECUTE PROCEDURE a_upd_album_cdtoc();
CREATE TRIGGER a_del_album_cdtoc AFTER DELETE ON album_cdtoc
    FOR EACH ROW EXECUTE PROCEDURE a_del_album_cdtoc();

-- Artist
CREATE TRIGGER a_iu_artist AFTER INSERT OR UPDATE ON artist 
    FOR EACH ROW EXECUTE PROCEDURE a_iu_entity();

-- Moderations
CREATE TRIGGER a_upd_moderation_open AFTER UPDATE ON moderation_open
    FOR EACH ROW EXECUTE PROCEDURE after_update_moderation_open();

-- Release events
CREATE TRIGGER b_iu_release BEFORE INSERT OR UPDATE ON release
    FOR EACH ROW EXECUTE PROCEDURE before_insertupdate_release();
CREATE TRIGGER a_ins_release AFTER INSERT ON release
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release();
CREATE TRIGGER a_upd_release AFTER UPDATE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release();
CREATE TRIGGER a_del_release AFTER DELETE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_del_release();
CREATE TRIGGER b_del_release BEFORE DELETE ON release
    FOR EACH ROW EXECUTE PROCEDURE b_del_entity();

-- album_amazon_asin
CREATE TRIGGER a_ins_album_amazon_asin AFTER INSERT ON album_amazon_asin
    FOR EACH ROW EXECUTE PROCEDURE a_ins_album_amazon_asin();
CREATE TRIGGER a_upd_album_amazon_asin AFTER UPDATE ON album_amazon_asin
    FOR EACH ROW EXECUTE PROCEDURE a_upd_album_amazon_asin();
CREATE TRIGGER a_del_album_amazon_asin AFTER DELETE ON album_amazon_asin
    FOR EACH ROW EXECUTE PROCEDURE a_del_album_amazon_asin();

-- Label
CREATE TRIGGER a_iu_label AFTER INSERT OR UPDATE ON label 
    FOR EACH ROW EXECUTE PROCEDURE a_iu_entity();

-- PUIDs
CREATE TRIGGER a_ins_puidjoin AFTER INSERT ON puidjoin
    FOR EACH ROW EXECUTE PROCEDURE a_ins_puidjoin();
CREATE TRIGGER a_del_puidjoin AFTER DELETE ON puidjoin
    FOR EACH ROW EXECUTE PROCEDURE a_del_puidjoin();

CREATE TRIGGER a_idu_puid_stat AFTER INSERT OR DELETE OR UPDATE ON puid_stat
    FOR EACH ROW EXECUTE PROCEDURE a_idu_puid_stat();
CREATE TRIGGER a_idu_puidjoin_stat AFTER INSERT OR DELETE OR UPDATE ON puidjoin_stat
    FOR EACH ROW EXECUTE PROCEDURE a_idu_puidjoin_stat();

-- Tags
CREATE TRIGGER a_ins_artist_tag AFTER INSERT ON artist_tag
    FOR EACH ROW EXECUTE PROCEDURE a_ins_tag();
CREATE TRIGGER a_del_artist_tag AFTER DELETE ON artist_tag
    FOR EACH ROW EXECUTE PROCEDURE a_del_tag();

CREATE TRIGGER a_ins_release_tag AFTER INSERT ON release_tag
     FOR EACH ROW EXECUTE PROCEDURE a_ins_tag();
CREATE TRIGGER a_del_release_tag AFTER DELETE ON release_tag
     FOR EACH ROW EXECUTE PROCEDURE a_del_tag();

CREATE TRIGGER a_ins_track_tag AFTER INSERT ON track_tag
    FOR EACH ROW EXECUTE PROCEDURE a_ins_tag();
CREATE TRIGGER a_del_track_tag AFTER DELETE ON track_tag
    FOR EACH ROW EXECUTE PROCEDURE a_del_tag();

CREATE TRIGGER a_ins_label_tag AFTER INSERT ON label_tag
    FOR EACH ROW EXECUTE PROCEDURE a_ins_tag();
CREATE TRIGGER a_del_label_tag AFTER DELETE ON label_tag
    FOR EACH ROW EXECUTE PROCEDURE a_del_tag();

-- Track
CREATE TRIGGER a_iu_track AFTER INSERT OR UPDATE ON track
    FOR EACH ROW EXECUTE PROCEDURE a_iu_entity();

-- vi: set ts=4 sw=4 et :
