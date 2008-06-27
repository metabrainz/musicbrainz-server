-- Abstract: copy the lookupcount column from the trm table and copy the
--           the data into the trm_stat table. trmjoin_stat table is also created

\set ON_ERROR_STOP 1

BEGIN;

-- tables

CREATE TABLE trm_stat
(
     id                  SERIAL,
     trm_id              INTEGER NOT NULL, -- references trm
     month_id            INTEGER NOT NULL,
     lookupcount         INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE trmjoin_stat
(
     id                  SERIAL,
     trmjoin_id          INTEGER NOT NULL, -- references trmjoin
     month_id            INTEGER NOT NULL,
     usecount            INTEGER NOT NULL DEFAULT 0
);

-- data
insert into trm_stat select nextval('trm_stat_id_seq'), id, 0, lookupcount from trm;

-- add new column to trmjoin
alter table trmjoin add column usecount integer; 
alter table trmjoin alter column usecount set default 0;

-- Optionally run this query -- it takes ass long!
--update trmjoin set usecount = 0 where usecount is null;

-- Set trm.lookupcount to NOT NULL.  All the existing rows are not null
-- already, but just in case ...
UPDATE trm SET lookupcount = 0 WHERE lookupcount IS NULL;
ALTER TABLE trm ALTER COLUMN lookupcount SET NOT NULL;

-- primary key

ALTER TABLE trm_stat ADD CONSTRAINT trm_stat_pkey PRIMARY KEY (id);
ALTER TABLE trmjoin_stat ADD CONSTRAINT trmjoin_stat_pkey PRIMARY KEY (id);

-- indexes

CREATE UNIQUE INDEX trm_stat_trm_idindex ON trm_stat (trm_id, month_id);
CREATE UNIQUE INDEX trmjoin_stat_trmjoin_idindex ON trmjoin_stat (trmjoin_id, month_id);
DROP INDEX trmjoin_trmindex;

-- We need to analyze trm_stat now so that the function we're about to create
-- generates a sensible query plan.  Come to think of it, should we recompile
-- all functions from time to time for the same reason?
COMMIT;
VACUUM ANALYZE trm_stat;
BEGIN;

-- FKs

ALTER TABLE trm_stat
    ADD CONSTRAINT trm_stat_fk_trm
    FOREIGN KEY (trm_id)
    REFERENCES trm(id)
    ON DELETE CASCADE;

ALTER TABLE trmjoin_stat
    ADD CONSTRAINT trmjoin_stat_fk_trmjoin
    FOREIGN KEY (trmjoin_id)
    REFERENCES trmjoin(id)
    ON DELETE CASCADE;

SELECT SETVAL('trm_stat_id_seq', c+1) FROM (SELECT MAX(id) AS c FROM trm_stat) t;
SELECT SETVAL('trmjoin_stat_id_seq', c+1) FROM (SELECT MAX(id) AS c FROM trmjoin_stat) t;

--'-----------------------------------------------------------------------------------
-- Changes to trm_stat/trmjoin_stat causes changes to trm.lookupcount/trmjoin.usecount
--'-----------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION a_idu_trm_stat () RETURNS trigger AS '
BEGIN
    IF (TG_OP = ''INSERT'' OR TG_OP = ''UPDATE'')
    THEN
        UPDATE trm SET lookupcount = (SELECT COALESCE(SUM(trm_stat.lookupcount), 0) FROM trm_stat WHERE trm_id = NEW.trm_id) WHERE id = NEW.trm_id;
        IF (TG_OP = ''UPDATE'')
        THEN
            IF (NEW.trm_id != OLD.trm_id)
            THEN
                UPDATE trm SET lookupcount = (SELECT COALESCE(SUM(trm_stat.lookupcount), 0) FROM trm_stat WHERE trm_id = OLD.trm_id) WHERE id = OLD.trm_id;
            END IF;
        END IF;
    ELSE
        UPDATE trm SET lookupcount = (SELECT COALESCE(SUM(trm_stat.lookupcount), 0) FROM trm_stat WHERE trm_id = OLD.trm_id) WHERE id = OLD.trm_id;
    END IF;

    RETURN NULL;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_idu_trmjoin_stat () RETURNS trigger AS '
BEGIN
    IF (TG_OP = ''INSERT'' OR TG_OP = ''UPDATE'')
    THEN
        UPDATE trmjoin SET usecount = (SELECT COALESCE(SUM(trmjoin_stat.usecount), 0) FROM trmjoin_stat WHERE trmjoin_id = NEW.trmjoin_id) WHERE id = NEW.trmjoin_id;
        IF (TG_OP = ''UPDATE'')
        THEN
            IF (NEW.trmjoin_id != OLD.trmjoin_id)
            THEN
                UPDATE trmjoin SET usecount = (SELECT COALESCE(SUM(trmjoin_stat.usecount), 0) FROM trmjoin_stat WHERE trmjoin_id = OLD.trmjoin_id) WHERE id = OLD.trmjoin_id;
            END IF;
        END IF;
    ELSE
        UPDATE trmjoin SET usecount = (SELECT COALESCE(SUM(trmjoin_stat.usecount), 0) FROM trmjoin_stat WHERE trmjoin_id = OLD.trmjoin_id) WHERE id = OLD.trmjoin_id;
    END IF;

    RETURN NULL;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER a_idu_trm_stat AFTER INSERT OR DELETE OR UPDATE ON trm_stat
    FOR EACH ROW EXECUTE PROCEDURE a_idu_trm_stat();
CREATE TRIGGER a_idu_trmjoin_stat AFTER INSERT OR DELETE OR UPDATE ON trmjoin_stat
    FOR EACH ROW EXECUTE PROCEDURE a_idu_trmjoin_stat();

-- Remove the update triggers on trmjoin:
DROP TRIGGER a_upd_trmjoin ON trmjoin;
DROP TRIGGER "reptg_trmjoin" on trmjoin;

-- Now re-create the replication trigger without UPDATE
CREATE TRIGGER "reptg_trmjoin"
AFTER INSERT OR DELETE ON "trmjoin"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

-- Do the same for TRM.  The live server is already correct, but since the
-- scripts in CVS have been wrong for a while, mirrors are likely incorrect.
DROP TRIGGER "reptg_trm" on trm;
CREATE TRIGGER "reptg_trm" 
AFTER INSERT OR DELETE ON "trm"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

COMMIT;

\unset ON_ERROR_STOP

-- vi: set ts=4 sw=4 et :
