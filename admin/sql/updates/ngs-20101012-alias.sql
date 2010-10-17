\set ON_ERROR_STOP 1
BEGIN;

DROP INDEX artist_alias_idx_name_artist;
DROP INDEX label_alias_idx_name_label;
DROP INDEX work_alias_idx_name_work;

CREATE UNIQUE INDEX artist_alias_idx_locale_artist ON artist_alias (artist, locale);
CREATE UNIQUE INDEX label_alias_idx_locale_label ON label_alias (label, locale);
CREATE UNIQUE INDEX work_alias_idx_locale_work ON work_alias (work, locale);

COMMIT;
