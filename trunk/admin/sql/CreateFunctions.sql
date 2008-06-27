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
-- All columns are non-null integers, except firstreleasedate
-- which is CHAR(10) WITH NULL
--'-----------------------------------------------------------------

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
   create temporary table albummeta_discids as select album.id, count(album_cdtoc.album) 
                from album left join album_cdtoc on album.id = album_cdtoc.album group by album.id;

   raise notice ''Counting puids'';
   create temporary table albummeta_puids as select album.id, count(puidjoin.track) 
                from album, albumjoin left join puidjoin on albumjoin.track = puidjoin.track 
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
            COALESCE(p.count, 0) AS puids,
            r.firstreleasedate,
            aws.asin,
            aws.coverarturl
    FROM    album a
            LEFT JOIN albummeta_tracks t ON t.id = a.id
            LEFT JOIN albummeta_discids d ON d.id = a.id
            LEFT JOIN albummeta_puids p ON p.id = a.id
            LEFT JOIN albummeta_firstreleasedate r ON r.id = a.id
            LEFT JOIN album_amazon_asin aws on aws.album = a.id
            ;

    ALTER TABLE albummeta ALTER COLUMN id SET NOT NULL;
    ALTER TABLE albummeta ALTER COLUMN tracks SET NOT NULL;
    ALTER TABLE albummeta ALTER COLUMN discids SET NOT NULL;
    ALTER TABLE albummeta ALTER COLUMN puids SET NOT NULL;
    -- firstreleasedate stays "WITH NULL"
    -- asin stays "WITH NULL"
    -- coverarturl stays "WITH NULL"

   ALTER TABLE albummeta ADD CONSTRAINT albummeta_pkey PRIMARY KEY (id);

   drop table albummeta_tracks;
   drop table albummeta_discids;
   drop table albummeta_puids;
   drop table albummeta_firstreleasedate;

   return 1;

end;
' language 'plpgsql';

--'-----------------------------------------------------------------
-- Keep lastupdated columns up to date
--'-----------------------------------------------------------------

create or replace function b_iu_update_lastmodified () returns TRIGGER as '
begin
    NEW.lastupdate = now(); 
    IF (TG_RELNAME = ''track'')
    THEN
        -- update the releases
        UPDATE album SET lastupdate = NOW() FROM albumjoin WHERE NEW.id = albumjoin.track and albumjoin.album = album.id;
    END IF;
    IF (TG_RELNAME = ''album'')
    THEN
        -- update the artist
        IF (NEW.artist != 1)
        THEN
            UPDATE artist SET lastupdate = NOW() WHERE artist.id = NEW.artist;
        END IF;
    END IF;
   return NEW;
end;
' language 'plpgsql';

--'-----------------------------------------------------------------
-- Keep rows in albummeta in sync with album
--'-----------------------------------------------------------------

create or replace function insert_album_meta () returns TRIGGER as $$
begin 
    insert into albummeta (id, tracks, discids, puids) values (NEW.id, 0, 0, 0); 
    insert into album_amazon_asin (album, lastupdate) values (NEW.id, '1970-01-01 00:00:00'); 
    
    return NEW; 
end; 
$$ language 'plpgsql';

create or replace function update_album_meta () returns TRIGGER as $$
begin
    if NEW.name != OLD.name 
    then
        update album_amazon_asin set lastupdate = '1970-01-01 00:00:00' where album = NEW.id; 
    end if;
   return NULL;
end;
$$ language 'plpgsql';

create or replace function delete_album_meta () returns TRIGGER as '
begin
   delete from albummeta where id = OLD.id;
   delete from album_amazon_asin where album = OLD.id;
   return OLD;
end;
' language 'plpgsql';

--'-----------------------------------------------------------------
-- Changes to albumjoin could cause changes to albummeta.tracks
-- and/or albummeta.puids and/org albummeta.puids
--'-----------------------------------------------------------------

create or replace function a_ins_albumjoin () returns trigger as '
begin
    UPDATE  albummeta
    SET     tracks = tracks + 1,
            puids = puids + (SELECT COUNT(*) FROM puidjoin WHERE track = NEW.track)
    WHERE   id = NEW.album;

    -- When a track is added to an album, update the albums lastupdate
    UPDATE  album SET lastupdate = NOW() WHERE album.id = NEW.album;

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
            puids = puids - (SELECT COUNT(*) FROM puidjoin WHERE track = OLD.track)
    WHERE   id = OLD.album;

    UPDATE  albummeta
    SET     tracks = tracks + 1,
            puids = puids + (SELECT COUNT(*) FROM puidjoin WHERE track = NEW.track)
    WHERE   id = NEW.album;

    -- When a track is added to an album, update the albums lastupdate
    UPDATE  album SET lastupdate = NOW() WHERE album.id = NEW.album;

    return NULL;
end;
' language 'plpgsql';
--'--
create or replace function a_del_albumjoin () returns trigger as $$
begin
    UPDATE  albummeta
    SET     tracks = tracks - 1,
            puids = puids - (SELECT COUNT(*) FROM puidjoin WHERE track = OLD.track)
    WHERE   id = OLD.album;

    -- When a track is removed from an album, update the albums lastupdate
    UPDATE  album SET lastupdate = NOW() WHERE album.id = OLD.album;

    return NULL;
end;
$$ language 'plpgsql';

--'-----------------------------------------------------------------
-- Changes to album_cdtoc could cause changes to albummeta.discids
--'-----------------------------------------------------------------

create or replace function a_ins_album_cdtoc () returns trigger as '
begin
    UPDATE  albummeta
    SET     discids = discids + 1
    WHERE   id = NEW.album;

    return NULL;
end;
' language 'plpgsql';
--'--
create or replace function a_upd_album_cdtoc () returns trigger as '
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
create or replace function a_del_album_cdtoc () returns trigger as '
begin
    UPDATE  albummeta
    SET     discids = discids - 1
    WHERE   id = OLD.album;

    return NULL;
end;
' language 'plpgsql';


--'-----------------------------------------------------------------
-- Changes to puidjoin could cause changes to albummeta.puids
--'-----------------------------------------------------------------

create or replace function a_ins_puidjoin () returns trigger as '
begin
    UPDATE  albummeta
    SET     puids = puids + 1
    WHERE   id IN (SELECT album FROM albumjoin WHERE track = NEW.track);

    return NULL;
end;
' language 'plpgsql';
--'--
create or replace function a_upd_puidjoin () returns trigger as '
begin
    if NEW.track = OLD.track
    then
        return NULL;
    end if;

    UPDATE  albummeta
    SET     puids = puids - 1
    WHERE   id IN (SELECT album FROM albumjoin WHERE track = OLD.track);

    UPDATE  albummeta
    SET     puids = puids + 1
    WHERE   id IN (SELECT album FROM albumjoin WHERE track = NEW.track);

    return NULL;
end;
' language 'plpgsql';
--'--
create or replace function a_del_puidjoin () returns trigger as '
begin
    UPDATE  albummeta
    SET     puids = puids - 1
    WHERE   id IN (SELECT album FROM albumjoin WHERE track = OLD.track);

    return NULL;
end;
' language 'plpgsql';
--'-----------------------------------------------------------------
-- When a moderation closes, move rows from _open to _closed
--'-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION after_update_moderation_open () RETURNS TRIGGER AS '
begin

    if (OLD.status IN (1,8) and NEW.status NOT IN (1,8)) -- STATUS_OPEN, STATUS_TOBEDELETED
    then
        -- Create moderation_closed record
        INSERT INTO moderation_closed SELECT * FROM moderation_open WHERE id = NEW.id;
        -- and update the closetime
        UPDATE moderation_closed SET closetime = NOW() WHERE id = NEW.id;

        -- Copy notes
        INSERT INTO moderation_note_closed
            SELECT * FROM moderation_note_open
            WHERE moderation = NEW.id;

        -- Copy votes
        INSERT INTO vote_closed
            SELECT * FROM vote_open
            WHERE moderation = NEW.id;

        -- Delete the _open records
        DELETE FROM vote_open WHERE moderation = NEW.id;
        DELETE FROM moderation_note_open WHERE moderation = NEW.id;
        DELETE FROM moderation_open WHERE id = NEW.id;
    end if;

    return NEW;
end;
' LANGUAGE 'plpgsql';

--'-----------------------------------------------------------------
-- Ensure release.releasedate is always valid
--'-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION before_insertupdate_release () RETURNS TRIGGER AS '
DECLARE
    y CHAR(4);
    m CHAR(2);
    d CHAR(2);
    teststr VARCHAR(10);
    testdate DATE;
BEGIN
    -- Check that the releasedate looks like this: yyyy-mm-dd
    IF (NOT(NEW.releasedate ~ ''^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$''))
    THEN
        RAISE EXCEPTION ''Invalid release date specification'';
    END IF;

    y := SUBSTR(NEW.releasedate, 1, 4);
    m := SUBSTR(NEW.releasedate, 6, 2);
    d := SUBSTR(NEW.releasedate, 9, 2);

    -- Disallow yyyy-00-dd
    IF (m = ''00'' AND d != ''00'')
    THEN
        RAISE EXCEPTION ''Invalid release date specification'';
    END IF;

    -- Check that the y/m/d combination is valid (e.g. disallow 2003-02-31)
    IF (m = ''00'') THEN m:= ''01''; END IF;
    IF (d = ''00'') THEN d:= ''01''; END IF;
    teststr := ( y || ''-'' || m || ''-'' || d );
    -- TO_DATE allows 2003-08-32 etc (it becomes 2003-09-01)
    -- So we will use the ::date cast, which catches this error
    testdate := teststr;

    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

--'-----------------------------------------------------------------
-- Maintain albummeta.firstreleasedate
--'-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION set_album_firstreleasedate(INTEGER)
RETURNS VOID AS '
BEGIN
    UPDATE albummeta SET firstreleasedate = (
        SELECT MIN(releasedate) FROM release WHERE album = $1
    ) WHERE id = $1;
    RETURN;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_release () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_album_firstreleasedate(NEW.album);
    UPDATE album SET lastupdate = NOW() WHERE id = NEW.album;
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_album_firstreleasedate(NEW.album);
    IF (OLD.album != NEW.album)
    THEN
        EXECUTE set_album_firstreleasedate(OLD.album);
    END IF;
    UPDATE album SET lastupdate = NOW() WHERE id = NEW.album;
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_album_firstreleasedate(OLD.album);
    UPDATE album SET lastupdate = NOW() WHERE id = OLD.album;
    RETURN OLD;
END;
' LANGUAGE 'plpgsql';

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

--'-----------------------------------------------------------------------------------
-- Changes to puid_stat/puidjoin_stat causes changes to puid.lookupcount/puidjoin.usecount
--'-----------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_idu_puid_stat () RETURNS trigger AS '
BEGIN
    IF (TG_OP = ''INSERT'' OR TG_OP = ''UPDATE'')
    THEN
        UPDATE puid SET lookupcount = (SELECT COALESCE(SUM(puid_stat.lookupcount), 0) FROM puid_stat WHERE puid_id = NEW.puid_id) WHERE id = NEW.puid_id;
        IF (TG_OP = ''UPDATE'')
        THEN
            IF (NEW.puid_id != OLD.puid_id)
            THEN
                UPDATE puid SET lookupcount = (SELECT COALESCE(SUM(puid_stat.lookupcount), 0) FROM puid_stat WHERE puid_id = OLD.puid_id) WHERE id = OLD.puid_id;
            END IF;
        END IF;
    ELSE
        UPDATE puid SET lookupcount = (SELECT COALESCE(SUM(puid_stat.lookupcount), 0) FROM puid_stat WHERE puid_id = OLD.puid_id) WHERE id = OLD.puid_id;
    END IF;

    RETURN NULL;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_idu_puidjoin_stat () RETURNS trigger AS '
BEGIN
    IF (TG_OP = ''INSERT'' OR TG_OP = ''UPDATE'')
    THEN
        UPDATE puidjoin SET usecount = (SELECT COALESCE(SUM(puidjoin_stat.usecount), 0) FROM puidjoin_stat WHERE puidjoin_id = NEW.puidjoin_id) WHERE id = NEW.puidjoin_id;
        IF (TG_OP = ''UPDATE'')
        THEN
            IF (NEW.puidjoin_id != OLD.puidjoin_id)
            THEN
                UPDATE puidjoin SET usecount = (SELECT COALESCE(SUM(puidjoin_stat.usecount), 0) FROM puidjoin_stat WHERE puidjoin_id = OLD.puidjoin_id) WHERE id = OLD.puidjoin_id;
            END IF;
        END IF;
    ELSE
        UPDATE puidjoin SET usecount = (SELECT COALESCE(SUM(puidjoin_stat.usecount), 0) FROM puidjoin_stat WHERE puidjoin_id = OLD.puidjoin_id) WHERE id = OLD.puidjoin_id;
    END IF;

    RETURN NULL;
END;
' LANGUAGE 'plpgsql';

create or replace function a_ins_tag () returns trigger as '
begin
    UPDATE  tag
    SET     refcount = refcount + 1
    WHERE   id = NEW.tag;

    return NULL;
end;
' language 'plpgsql';

create or replace function a_del_tag () returns trigger as '
declare
    ref_count integer;
begin

    SELECT INTO ref_count refcount FROM tag WHERE id = OLD.tag;
    IF ref_count = 1 THEN
         DELETE FROM tag WHERE id = OLD.tag;
    ELSE
         UPDATE  tag
         SET     refcount = refcount - 1
         WHERE   id = OLD.tag;
    END IF;

    return NULL;
end;
' language 'plpgsql';

--'-- vi: set ts=4 sw=4 et :
