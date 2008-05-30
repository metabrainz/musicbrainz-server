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
DROP TRIGGER a_ins_artist_tag ON artist_tag;
DROP TRIGGER a_del_artist_tag ON artist_tag;
DROP TRIGGER a_ins_release_tag ON release_tag;
DROP TRIGGER a_del_release_tag ON release_tag;
DROP TRIGGER a_ins_track_tag ON track_tag;
DROP TRIGGER a_del_track_tag ON track_tag;
DROP TRIGGER a_ins_label_tag ON label_tag;
DROP TRIGGER a_del_label_tag ON label_tag;

-- vi: set ts=4 sw=4 et :
