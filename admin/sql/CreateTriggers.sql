\set ON_ERROR_STOP 1
create trigger a_ins_album after insert on album 
               for each row execute procedure insert_album_meta();

create trigger a_del_album after delete on album 
               for each row execute procedure delete_album_meta();

create trigger a_ins_albumjoin after insert on albumjoin 
               for each row execute procedure increment_track_count();

create trigger a_del_albumjoin after delete on albumjoin 
               for each row execute procedure decrement_track_count();

create trigger a_ins_discid after insert on discid 
               for each row execute procedure increment_discid_count();

create trigger a_del_discid after delete on discid 
               for each row execute procedure decrement_discid_count();

create trigger a_ins_trmjoin after insert on trmjoin 
               for each row execute procedure increment_trmid_count();

create trigger a_del_trmjoin after delete on trmjoin 
               for each row execute procedure decrement_trmid_count();
