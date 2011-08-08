BEGIN;

DELETE FROM isrc WHERE isrc !~ E'^[A-Z]{2}[A-Z0-9]{3}[0-9]{7}$';
ALTER TABLE isrc ADD CONSTRAINT isrc_check_isrc CHECK (isrc ~ E'^[A-Z]{2}[A-Z0-9]{3}[0-9]{7}$');
ALTER TABLE work ADD CONSTRAINT work_check_iswc CHECK (iswc IS NULL OR iswc ~ E'^T-?\\d{3}\.?\\d{3}\.?\\d{3}[-.]?\\d$');

COMMIT;
