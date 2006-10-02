\set ON_ERROR_STOP 1

--'-----------------------------------------------------------------
-- Populate the track_firstreleasedate table, one-to-one join with track.
-- All columns are non-null integers, except firstreleasedate
-- which is CHAR(10) WITH NULL
--'-----------------------------------------------------------------

create or replace function fill_track_firstreleasedate () returns integer as '
begin

   raise notice ''Dropping track_firstreleasedate table'';
   BEGIN
       drop table track_firstreleasedate;
   EXCEPTION
       WHEN undefined_table THEN
           NULL;  -- ignore the error
   END;

   raise notice ''Creating new track_firstreleasedate table'';
   SELECT track.id, firstreleasedate
     INTO track_firstreleasedate 
     FROM albummeta, track, albumjoin 
    WHERE albumjoin.album = albummeta.id 
      AND albumjoin.track = track.id;

   raise notice ''Creating track_firstreleasedate constraints'';
   ALTER TABLE track_firstreleasedate ALTER COLUMN id SET NOT NULL;
   ALTER TABLE track_firstreleasedate ADD CONSTRAINT track_firstreleasedate_pkey PRIMARY KEY (id);

   raise notice ''Creating track_firstreleasedate foreign keys'';
   ALTER TABLE track_firstreleasedate
    ADD CONSTRAINT track_firstreleasedate_fk_track
    FOREIGN KEY (id)
    REFERENCES track(id);

   raise notice ''Creating track_firstreleasedate index'';
   CREATE INDEX track_firstreleasedate_dateindex ON track_firstreleasedate (firstreleasedate);

   return 1;

end;
' language 'plpgsql';

--'-----------------------------------------------------------------
-- Maintain track_firstreleasedate when releases are changed
--'-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION set_album_firstreleasedate_frd(INTEGER)
RETURNS VOID AS '
BEGIN
    UPDATE track_firstreleasedate SET firstreleasedate = (
        SELECT MIN(releasedate) FROM release WHERE album = $1
    ) WHERE id in (
        SELECT albumjoin.track from albumjoin where album = $1
    );
    RETURN;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_release_frd () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_album_firstreleasedate_frd(NEW.album);
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release_frd () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_album_firstreleasedate_frd(NEW.album);
    IF (OLD.album != NEW.album)
    THEN
        EXECUTE set_album_firstreleasedate_frd(OLD.album);
    END IF;
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release_frd () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_album_firstreleasedate_frd(OLD.album);
    RETURN OLD;
END;
' LANGUAGE 'plpgsql';

--'-----------------------------------------------------------------
-- Maintain track_firstreleasedate when tracks are added to a release
--'-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION set_track_firstreleasedate_frd(INTEGER, INTEGER)
RETURNS VOID AS '
BEGIN
    UPDATE track_firstreleasedate SET firstreleasedate = (
        SELECT MIN(releasedate) FROM release WHERE album = $1
    ) WHERE id = $2;
    RETURN;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_albumjoin_frd () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_track_firstreleasedate_frd(NEW.album, NEW.track);
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_albumjoin_frd () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_track_firstreleasedate_frd(NEW.album, NEW.track);
    IF (OLD.album != NEW.album)
    THEN
        EXECUTE set_track_firstreleasedate_frd(OLD.album, OLD.track);
    END IF;
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_albumjoin_frd () RETURNS TRIGGER AS '
BEGIN
    UPDATE track_firstreleasedate SET firstreleasedate = (
        SELECT MIN(releasedate) FROM release WHERE album = (
            SELECT album from albumjoin where track = OLD.track
        )
    ) WHERE id = OLD.track;
    --EXECUTE set_track_firstreleasedate_frd(OLD.album, old.track);
    RETURN OLD;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_track_frd () RETURNS TRIGGER AS '
BEGIN
    INSERT INTO track_firstreleasedate (id, firstreleasedate) values (NEW.id, ''          '');
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION b_del_track_frd () RETURNS TRIGGER AS '
BEGIN
    DELETE FROM track_firstreleasedate where id = OLD.id;
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

--'-- vi: set ts=4 sw=4 et :
