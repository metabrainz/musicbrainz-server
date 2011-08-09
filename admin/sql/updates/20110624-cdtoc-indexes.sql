CREATE UNIQUE INDEX cdtoc_idx_discid ON cdtoc (discid);
CREATE INDEX cdtoc_idx_freedb_id ON cdtoc (freedb_id);
CREATE INDEX medium_cdtoc_idx_cdtoc ON medium_cdtoc (cdtoc);

