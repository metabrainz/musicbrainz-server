-- Abstract: Add the album_amazon_asin table, related structures and data

\set ON_ERROR_STOP 1

BEGIN;

create table album_amazon_asin (
        album           INTEGER NOT NULL, -- references Album
        asin            CHAR(10),
        coverarturl     VARCHAR(255),
        lastupdate      timestamp with time zone default now()
);

-- Paste data in here before running :-)
COPY album_amazon_asin FROM STDIN;
\.

ALTER TABLE album_amazon_asin ADD CONSTRAINT album_amazon_asin_pkey PRIMARY KEY (album);
CREATE INDEX album_amazon_asin_asin ON album_amazon_asin (asin);

-- Some data may be in the dump for albums which no longer exist
-- Delete those rows
DELETE FROM album_amazon_asin WHERE NOT EXISTS (
    SELECT 1 FROM album WHERE id = album_amazon_asin.album
);

ALTER TABLE album_amazon_asin
    ADD CONSTRAINT album_amazon_asin_fk_album
    FOREIGN KEY (album)
    REFERENCES album(id)
    ON DELETE CASCADE;

-- Update the structure and data of the albummeta table

SELECT m.*, z.asin, z.coverarturl
INTO TEMPORARY TABLE tmp_albummeta
FROM albummeta m LEFT JOIN album_amazon_asin z ON z.album = m.id;

DELETE FROM albummeta;
ALTER TABLE albummeta ADD COLUMN asin CHAR(10);
ALTER TABLE albummeta ADD COLUMN coverarturl VARCHAR(255);

INSERT INTO albummeta SELECT * FROM tmp_albummeta;
DROP TABLE tmp_albummeta;

-- Various functions and triggers

create or replace function fill_album_meta () returns integer as '
declare

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

    raise notice ''Finding first release dates'';
    CREATE TEMPORARY TABLE albummeta_firstreleasedate AS
        SELECT  album AS id, MIN(releasedate)::CHAR(10) AS firstreleasedate
        FROM    release
        GROUP BY album;

   raise notice ''Creating albummeta table'';
   create table albummeta as
   select a.id,
            COALESCE(t.count, 0) AS tracks,
            COALESCE(d.count, 0) AS discids,
            COALESCE(m.count, 0) AS trmids,
            r.firstreleasedate,
            aws.asin,
            aws.coverarturl
    FROM    album a
            LEFT JOIN albummeta_tracks t ON t.id = a.id
            LEFT JOIN albummeta_discids d ON d.id = a.id
            LEFT JOIN albummeta_trmids m ON m.id = a.id
            LEFT JOIN albummeta_firstreleasedate r ON r.id = a.id
            LEFT JOIN album_amazon_asin aws on aws.album = a.id
            ;

    ALTER TABLE albummeta ALTER COLUMN id SET NOT NULL;
    ALTER TABLE albummeta ALTER COLUMN tracks SET NOT NULL;
    ALTER TABLE albummeta ALTER COLUMN discids SET NOT NULL;
    ALTER TABLE albummeta ALTER COLUMN trmids SET NOT NULL;
    -- firstreleasedate stays "WITH NULL"
    -- asin stays "WITH NULL"
    -- coverarturl stays "WITH NULL"

   create unique index albummeta_id on albummeta(id);

   drop table albummeta_tracks;
   drop table albummeta_discids;
   drop table albummeta_trmids;
   drop table albummeta_firstreleasedate;

   return 1;

end;
' language 'plpgsql';

--'-----------------------------------------------------------------
-- Keep rows in albummeta in sync with album
--'-----------------------------------------------------------------

create or replace function insert_album_meta () returns TRIGGER as '
begin 
    insert into albummeta (id, tracks, discids, trmids) values (NEW.id, 0, 0, 0); 
    insert into album_amazon_asin (album, lastupdate) values (NEW.id, \'1970-01-01 00:00:00\'); 
    
    return NEW; 
end; 
' language 'plpgsql';

create or replace function update_album_meta () returns TRIGGER as '
begin
    if NEW.name != OLD.name 
    then
        update album_amazon_asin set lastupdate = \'1970-01-01 00:00:00\' where album = NEW.id; 
    end if;
   return NULL;
end;
' language 'plpgsql';

create or replace function delete_album_meta () returns TRIGGER as '
begin
   delete from albummeta where id = OLD.id;
   delete from album_amazon_asin where album = OLD.id;
   return OLD;
end;
' language 'plpgsql';

--'-----------------------------------------------------------------
-- Changes to album_amazon_asin should cause changes to albummeta.asin
--'-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION set_album_asin(INTEGER)
RETURNS VOID AS '
BEGIN
    UPDATE albummeta SET coverarturl = (
        SELECT coverarturl FROM album_amazon_asin WHERE album = $1
    ), asin = (
        SELECT asin FROM album_amazon_asin WHERE album = $1
    ) WHERE id = $1;
    RETURN;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_album_amazon_asin () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_album_asin(NEW.album);
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_album_amazon_asin () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_album_asin(NEW.album);
    IF (OLD.album != NEW.album)
    THEN
        EXECUTE set_album_asin(OLD.album);
    END IF;
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_album_amazon_asin () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_album_asin(OLD.album);
    RETURN OLD;
END;
' LANGUAGE 'plpgsql';

create trigger a_upd_album after update on album 
               for each row execute procedure update_album_meta();

CREATE TRIGGER a_ins_album_amazon_asin AFTER INSERT ON album_amazon_asin
    FOR EACH ROW EXECUTE PROCEDURE a_ins_album_amazon_asin();
CREATE TRIGGER a_upd_album_amazon_asin AFTER UPDATE ON album_amazon_asin
    FOR EACH ROW EXECUTE PROCEDURE a_upd_album_amazon_asin();
CREATE TRIGGER a_del_album_amazon_asin AFTER DELETE ON album_amazon_asin
    FOR EACH ROW EXECUTE PROCEDURE a_del_album_amazon_asin();

COMMIT;

VACUUM ANALYZE album_amazon_asin;
VACUUM ANALYZE albummeta;

-- vi: set ts=4 sw=4 et :
