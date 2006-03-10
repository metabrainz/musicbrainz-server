\unset ON_ERROR_STOP

-- TODO order this

DROP TRIGGER a_del_album ON album;
DROP TRIGGER a_upd_album ON album;
DROP TRIGGER a_ins_album ON album;
DROP TRIGGER a_del_albumjoin ON albumjoin;
DROP TRIGGER a_upd_albumjoin ON albumjoin;
DROP TRIGGER a_ins_albumjoin ON albumjoin;
DROP TRIGGER a_del_album_cdtoc ON album_cdtoc;
DROP TRIGGER a_upd_album_cdtoc ON album_cdtoc;
DROP TRIGGER a_ins_album_cdtoc ON album_cdtoc;
DROP TRIGGER a_del_trmjoin ON trmjoin;
DROP TRIGGER a_ins_trmjoin ON trmjoin;
DROP TRIGGER a_idu_trm_stat ON trm_stat;
DROP TRIGGER a_idu_trmjoin_stat ON trmjoin_stat;
DROP TRIGGER a_upd_moderation_open ON moderation_open;
DROP TRIGGER b_iu_release ON release;
DROP TRIGGER a_ins_release ON release;
DROP TRIGGER a_upd_release ON release;
DROP TRIGGER a_del_release ON release;
DROP TRIGGER a_ins_album_amazon_asin ON album_amazon_asin;
DROP TRIGGER a_upd_album_amazon_asin ON album_amazon_asin;
DROP TRIGGER a_del_album_amazon_asin ON album_amazon_asin;
DROP TRIGGER a_del_puidjoin ON puidjoin;
DROP TRIGGER a_ins_puidjoin ON puidjoin;
DROP TRIGGER a_idu_puid_stat ON puid_stat;
DROP TRIGGER a_idu_puidjoin_stat ON puidjoin_stat;

-- vi: set ts=4 sw=4 et :
