\set ON_ERROR_STOP 1

create or replace function fill_album_meta () returns integer as '
declare

   data        record;
   num_trms    integer;
   num_tracks  integer;
   num_discids integer;
   table_count integer;

begin

   table_count := (SELECT count(*) FROM pg_class WHERE relname = ''albummeta'');
   if table_count > 0 then
       raise notice ''Dropping existing albummeta table'';
       drop table albummeta;
   end if;

   raise notice ''Counting tracks'';
   create table albummeta_tracks as select album.id, count(albumjoin.album) 
                from album left join albumjoin on album.id = albumjoin.album group by album.id;

   raise notice ''Counting discids'';
   create table albummeta_discids as select album.id, count(discid.album) 
                from album left join discid on album.id = discid.album group by album.id;

   raise notice ''Counting trmids'';
   create table albummeta_trmids as select album.id, count(trmjoin.track) 
                from album, albumjoin left join trmjoin on albumjoin.track = trmjoin.track 
                where album.id = albumjoin.album group by album.id;

   raise notice ''Creating albumeta table'';
   create table albummeta as select albummeta_tracks.id as id, albummeta_tracks.count as tracks,
                albummeta_discids.count as discids, albummeta_trmids.count as trmids 
                where albummeta_tracks.id = albummeta_discids.id and 
                albummeta_tracks.id = albummeta_trmids.id;

   create unique index albummeta_id on albummeta(id);

   drop table albummeta_tracks;
   drop table albummeta_discids;
   drop table albummeta_trmids;

   return 1;

end;
' language 'plpgsql';

--------------------------------------------------------------------
create or replace function insert_album_meta () returns opaque as '
begin

   insert into albummeta (id, tracks, discids, trmids) values (NEW.id, 0, 0, 0);
   return NEW;

end;
' language 'plpgsql';

--------------------------------------------------------------------
create or replace function delete_album_meta () returns opaque as '
begin

   delete from albummeta where id = OLD.id;
   return OLD;

end;
' language 'plpgsql';

--------------------------------------------------------------------
create or replace function increment_track_count () returns opaque as '
begin

   update albummeta set tracks = tracks + 1 where id = NEW.album;
   return NEW;

end;
' language 'plpgsql';

--------------------------------------------------------------------
create or replace function decrement_track_count () returns opaque as '
begin

   update albummeta set tracks = tracks - 1 where id = OLD.album;
   return OLD;

end;
' language 'plpgsql';

--------------------------------------------------------------------
create or replace function increment_discid_count () returns opaque as '
begin

   update albummeta set discids = discids + 1 where id = NEW.album;
   return NEW;

end;
' language 'plpgsql';

--------------------------------------------------------------------
create or replace function decrement_discid_count () returns opaque as '
begin

   update albummeta set discids = discids - 1 where id = OLD.album;
   return OLD;

end;
' language 'plpgsql';

--------------------------------------------------------------------
create or replace function increment_trmid_count () returns opaque as '
begin

   
   update albummeta set trmids = trmids + 1 where id in 
      (select distinct album from albumjoin where track = NEW.track);
   return NEW;

end;
' language 'plpgsql';

--------------------------------------------------------------------
create or replace function decrement_trmid_count () returns opaque as '
begin

   update albummeta set trmids = trmids - 1 where id in
      (select distinct album from albumjoin where track = OLD.track);
   return OLD;

end;
' language 'plpgsql';
--------------------------------------------------------------------
create or replace function before_update_moderation () returns opaque as '
begin

   if (OLD.status = 1 and NEW.status != 1) -- STATUS_OPEN
   then
      NEW.closetime := NOW();
   end if;

   return NEW;

end;
' language 'plpgsql';
