\unset ON_ERROR_STOP

-- Alphabetical order by table

ALTER TABLE cdtoc_raw DROP CONSTRAINT cdtoc_raw_fk_release_raw;
ALTER TABLE track_raw DROP CONSTRAINT track_raw_fk_release_raw;

-- vi: set ts=4 sw=4 et :
