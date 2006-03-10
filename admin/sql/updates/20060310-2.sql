-- Abstract: add the wiki_transclusion table

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE puid ADD CONSTRAINT puid_pkey PRIMARY KEY (id);
ALTER TABLE puid_stat ADD CONSTRAINT puid_stat_pkey PRIMARY KEY (id);
ALTER TABLE puidjoin ADD CONSTRAINT puidjoin_pkey PRIMARY KEY (id);
ALTER TABLE puidjoin_stat ADD CONSTRAINT puidjoin_stat_pkey PRIMARY KEY (id);

CREATE UNIQUE INDEX puid_puidindex ON puid (puid);
CREATE UNIQUE INDEX puid_stat_puid_idindex ON puid_stat (puid_id, month_id);
CREATE INDEX puidjoin_trackindex ON puidjoin (track);
CREATE UNIQUE INDEX puidjoin_puidtrack ON puidjoin (puid, track);
CREATE UNIQUE INDEX puidjoin_stat_puidjoin_idindex ON puidjoin_stat (puidjoin_id, month_id);

ALTER TABLE puid
    ADD CONSTRAINT puid_fk_clientversion
    FOREIGN KEY (version)
    REFERENCES clientversion(id);
ALTER TABLE puidjoin
    ADD CONSTRAINT puidjoin_fk_track
    FOREIGN KEY (track)
    REFERENCES track(id);
ALTER TABLE puidjoin
    ADD CONSTRAINT puidjoin_fk_puid
    FOREIGN KEY (puid)
    REFERENCES puid(id);
ALTER TABLE puidjoin_stat
    ADD CONSTRAINT puidjoin_stat_fk_puidjoin
    FOREIGN KEY (puidjoin_id)
    REFERENCES puidjoin(id)
    ON DELETE CASCADE;
ALTER TABLE puid_stat
    ADD CONSTRAINT puid_stat_fk_puid
    FOREIGN KEY (puid_id)
    REFERENCES puid(id)
    ON DELETE CASCADE;

--these are not needed since we are recreating all the triggers
--CREATE TRIGGER a_ins_puidjoin AFTER INSERT ON puidjoin
--       FOR EACH ROW EXECUTE PROCEDURE a_ins_puidjoin();
--       CREATE TRIGGER a_del_puidjoin AFTER DELETE ON puidjoin
--       FOR EACH ROW EXECUTE PROCEDURE a_del_puidjoin();
--
--CREATE TRIGGER a_idu_puid_stat AFTER INSERT OR DELETE OR UPDATE ON puid_stat
--       FOR EACH ROW EXECUTE PROCEDURE a_idu_puid_stat();
--       CREATE TRIGGER a_idu_puidjoin_stat AFTER INSERT OR DELETE OR UPDATE ON puidjoin_stat
--       FOR EACH ROW EXECUTE PROCEDURE a_idu_puidjoin_stat();

vacuum analyze puid;
vacuum analyze puidjoin;

COMMIT;

-- vi: set ts=4 sw=4 et :
