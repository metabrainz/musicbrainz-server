drop function fill_album_meta();
drop function insert_album_meta();
drop function delete_album_meta();
drop function increment_track_count();
drop function decrement_track_count();
drop function increment_discid_count();
drop function decrement_discid_count();
drop function increment_trmid_count();
drop function decrement_trmid_count();

drop trigger a_ins_album on album; 
drop trigger a_del_album on album; 
drop trigger a_ins_albumjoin on albumjoin; 
drop trigger a_del_albumjoin on albumjoin; 
drop trigger a_ins_discid on discid; 
drop trigger a_del_discid on discid; 
drop trigger a_ins_trmjoin on trmjoin; 
drop trigger a_del_trmjoin on trmjoin; 
