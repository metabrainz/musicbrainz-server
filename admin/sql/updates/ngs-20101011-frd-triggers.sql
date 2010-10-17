\set ON_ERROR_STOP 1
BEGIN;

CREATE OR REPLACE FUNCTION a_ins_release() RETURNS trigger AS $$
BEGIN
    -- increment refcount of the name
    PERFORM inc_refcount('artist_credit', NEW.artist_credit, 1);
    -- increment releasecount of the parent release group
    UPDATE release_group_meta SET releasecount = releasecount + 1 WHERE id = NEW.release_group;
    PERFORM set_release_group_firstreleasedate(NEW.release_group);
    -- add new release_meta
    INSERT INTO release_meta (id) VALUES (NEW.id);
    INSERT INTO release_coverart (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release() RETURNS trigger AS $$
BEGIN
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_refcount('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_refcount('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.release_group != OLD.release_group THEN
        -- release group is changed, decrement releasecount in the original RG, increment in the new one
        UPDATE release_group_meta SET releasecount = releasecount - 1 WHERE id = OLD.release_group;
        UPDATE release_group_meta SET releasecount = releasecount + 1 WHERE id = NEW.release_group;
        PERFORM set_release_group_firstreleasedate(OLD.release_group);
    END IF;
    PERFORM set_release_group_firstreleasedate(NEW.release_group);
    IF NEW.editpending = OLD.editpending THEN
        -- editpending is unchanged and we are in UPDATE query, that means some data have changed
        UPDATE release_meta SET lastupdate=NOW() WHERE id=NEW.id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release() RETURNS trigger AS $$
BEGIN
    -- decrement refcount of the name
    PERFORM dec_refcount('artist_credit', OLD.artist_credit, 1);
    -- decrement releasecount of the parent release group
    UPDATE release_group_meta SET releasecount = releasecount - 1 WHERE id = OLD.release_group;
    PERFORM set_release_group_firstreleasedate(OLD.release_group);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------
-- Maintain release_group_meta.firstreleasedate
-------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_release_group_firstreleasedate(release_group_id INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE release_group_meta SET firstreleasedate_year = first.date_year,
                                  firstreleasedate_month = first.date_month,
                                  firstreleasedate_day = first.date_day
      FROM (
        SELECT date_year, date_month, date_day FROM release
         WHERE release_group = release_group_id
      ORDER BY date_year NULLS LAST, date_month NULLS LAST, date_day NULLS LAST
         LIMIT 1
           ) AS first WHERE id = release_group_id;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
