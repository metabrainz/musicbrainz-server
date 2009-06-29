BEGIN;

CREATE UNIQUE INDEX artist_alias_idx_name_artist ON artist_alias (name, artist);
CREATE UNIQUE INDEX label_alias_idx_name_label ON label_alias (name, label);

COMMIT;
