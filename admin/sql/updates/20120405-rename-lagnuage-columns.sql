-- MBS-1799, Add ISO 639-3 language codes to the database

ALTER TABLE language ADD COLUMN iso_code_3 CHAR(3);
ALTER TABLE language RENAME COLUMN iso_code_2 TO iso_code_1;
ALTER TABLE language RENAME COLUMN iso_code_3b TO iso_code_2b;
ALTER TABLE language RENAME COLUMN iso_code_3t TO iso_code_2t;
ALTER INDEX language_idx_iso_code_2 RENAME TO language_idx_iso_code_1;
ALTER INDEX language_idx_iso_code_3b RENAME TO language_idx_iso_code_2b;
ALTER INDEX language_idx_iso_code_3t RENAME TO language_idx_iso_code_2t;

ALTER TABLE language ALTER COLUMN iso_code_2b DROP NOT NULL;
ALTER TABLE language ALTER COLUMN iso_code_2t DROP NOT NULL;

