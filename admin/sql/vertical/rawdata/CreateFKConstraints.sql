\set ON_ERROR_STOP 1

-- Alphabetical order by table, then constraint

-- No BEGIN/COMMIT here.  Each FK is created in its own transaction;
-- this is mainly because if you're setting up a big database, it
-- could get really annoying if it takes a long time to create the FKs,
-- only for the last one to fail and the whole lot gets rolled back.
-- It should also be more efficient, of course.

ALTER TABLE cdtoc_raw
    ADD CONSTRAINT cdtoc_raw_fk_release_raw
    FOREIGN KEY (release)
    REFERENCES release_raw(id);

ALTER TABLE track_raw
    ADD CONSTRAINT track_raw_fk_release_raw
    FOREIGN KEY (release)
    REFERENCES release_raw(id);

-- vi: set ts=4 sw=4 et :
