\set ON_ERROR_STOP 1

--'-----------------------------------------------------------------
-- The join(VARCHAR) aggregate
--'-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION join_append(VARCHAR, VARCHAR)
RETURNS VARCHAR AS '
DECLARE
    state ALIAS FOR $1;
    value ALIAS FOR $2;
BEGIN
    IF (value IS NULL) THEN RETURN state; END IF;
    IF (state IS NULL) THEN
        RETURN value;
    ELSE
        RETURN(state || '' '' || value);
    END IF;
END;
' LANGUAGE 'plpgsql';

CREATE AGGREGATE join(BASETYPE = VARCHAR, SFUNC=join_append, STYPE=VARCHAR);

--'-----------------------------------------------------------------
-- Populate the albummeta table, one-to-one join with album.
-- All columns are non-null integers.
--'-----------------------------------------------------------------

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
   create temporary table albummeta_tracks as select album.id, count(albumjoin.album) 
                from album left join albumjoin on album.id = albumjoin.album group by album.id;

   raise notice ''Counting discids'';
   create temporary table albummeta_discids as select album.id, count(discid.album) 
                from album left join discid on album.id = discid.album group by album.id;

   raise notice ''Counting trmids'';
   create temporary table albummeta_trmids as select album.id, count(trmjoin.track) 
                from album, albumjoin left join trmjoin on albumjoin.track = trmjoin.track 
                where album.id = albumjoin.album group by album.id;

   raise notice ''Creating albummeta table'';
   create table albummeta as
   select a.id,
            COALESCE(t.count, 0) AS tracks,
            COALESCE(d.count, 0) AS discids,
            COALESCE(m.count, 0) AS trmids
    FROM    album a
            LEFT JOIN albummeta_tracks t ON t.id = a.id
            LEFT JOIN albummeta_discids d ON d.id = a.id
            LEFT JOIN albummeta_trmids m ON m.id = a.id
            ;

    ALTER TABLE albummeta ALTER COLUMN id SET NOT NULL;
    ALTER TABLE albummeta ALTER COLUMN tracks SET NOT NULL;
    ALTER TABLE albummeta ALTER COLUMN discids SET NOT NULL;
    ALTER TABLE albummeta ALTER COLUMN trmids SET NOT NULL;

   create unique index albummeta_id on albummeta(id);

   drop table albummeta_tracks;
   drop table albummeta_discids;
   drop table albummeta_trmids;

   return 1;

end;
' language 'plpgsql';

--'-----------------------------------------------------------------
-- Keep rows in albummeta in sync with album
--'-----------------------------------------------------------------

create or replace function insert_album_meta () returns TRIGGER as '
begin
   insert into albummeta (id, tracks, discids, trmids) values (NEW.id, 0, 0, 0);
   return NEW;
end;
' language 'plpgsql';

create or replace function delete_album_meta () returns TRIGGER as '
begin
   delete from albummeta where id = OLD.id;
   return OLD;
end;
' language 'plpgsql';

--'-----------------------------------------------------------------
-- Changes to albumjoin could cause changes to albummeta.tracks
-- and/or albummeta.trmids
--'-----------------------------------------------------------------

create or replace function a_ins_albumjoin () returns trigger as '
begin
    UPDATE  albummeta
    SET     tracks = tracks + 1,
            trmids = trmids + (SELECT COUNT(*) FROM trmjoin WHERE track = NEW.track)
    WHERE   id = NEW.album;

    return NULL;
end;
' language 'plpgsql';
--'--
create or replace function a_upd_albumjoin () returns trigger as '
begin
    if NEW.album = OLD.album AND NEW.track = OLD.track
    then
        return NULL;
    end if;

    UPDATE  albummeta
    SET     tracks = tracks - 1,
            trmids = trmids - (SELECT COUNT(*) FROM trmjoin WHERE track = OLD.track)
    WHERE   id = OLD.album;

    UPDATE  albummeta
    SET     tracks = tracks + 1,
            trmids = trmids + (SELECT COUNT(*) FROM trmjoin WHERE track = NEW.track)
    WHERE   id = NEW.album;

    return NULL;
end;
' language 'plpgsql';
--'--
create or replace function a_del_albumjoin () returns trigger as '
begin
    UPDATE  albummeta
    SET     tracks = tracks - 1,
            trmids = trmids - (SELECT COUNT(*) FROM trmjoin WHERE track = OLD.track)
    WHERE   id = OLD.album;

    return NULL;
end;
' language 'plpgsql';

--'-----------------------------------------------------------------
-- Changes to discid could cause changes to albummeta.discids
--'-----------------------------------------------------------------

create or replace function a_ins_discid () returns trigger as '
begin
    UPDATE  albummeta
    SET     discids = discids + 1
    WHERE   id = NEW.album;

    return NULL;
end;
' language 'plpgsql';
--'--
create or replace function a_upd_discid () returns trigger as '
begin
    if NEW.album = OLD.album
    then
        return NULL;
    end if;

    UPDATE  albummeta
    SET     discids = discids - 1
    WHERE   id = OLD.album;

    UPDATE  albummeta
    SET     discids = discids + 1
    WHERE   id = NEW.album;

    return NULL;
end;
' language 'plpgsql';
--'--
create or replace function a_del_discid () returns trigger as '
begin
    UPDATE  albummeta
    SET     discids = discids - 1
    WHERE   id = OLD.album;

    return NULL;
end;
' language 'plpgsql';

--'-----------------------------------------------------------------
-- Changes to trmjoin could cause changes to albummeta.trmids
--'-----------------------------------------------------------------

create or replace function a_ins_trmjoin () returns trigger as '
begin
    UPDATE  albummeta
    SET     trmids = trmids + 1
    WHERE   id IN (SELECT album FROM albumjoin WHERE track = NEW.track);

    return NULL;
end;
' language 'plpgsql';
--'--
create or replace function a_upd_trmjoin () returns trigger as '
begin
    if NEW.track = OLD.track
    then
        return NULL;
    end if;

    UPDATE  albummeta
    SET     trmids = trmids - 1
    WHERE   id IN (SELECT album FROM albumjoin WHERE track = OLD.track);

    UPDATE  albummeta
    SET     trmids = trmids + 1
    WHERE   id IN (SELECT album FROM albumjoin WHERE track = NEW.track);

    return NULL;
end;
' language 'plpgsql';
--'--
create or replace function a_del_trmjoin () returns trigger as '
begin
    UPDATE  albummeta
    SET     trmids = trmids - 1
    WHERE   id IN (SELECT album FROM albumjoin WHERE track = OLD.track);

    return NULL;
end;
' language 'plpgsql';

--'-----------------------------------------------------------------
-- Set moderation.closetime when each moderation closes
--'-----------------------------------------------------------------

create or replace function before_update_moderation () returns TRIGGER as '
begin

   if (OLD.status = 1 and NEW.status != 1) -- STATUS_OPEN
   then
      NEW.closetime := NOW();
   end if;

   return NEW;

end;
' language 'plpgsql';

--'-- vi: set ts=4 sw=4 et :
