\set ON_ERROR_STOP 1

-- Alphabetical order by table

CREATE INDEX album_artistindex ON album (artist);
CREATE UNIQUE INDEX album_gidindex ON album (gid);
CREATE INDEX album_nameindex ON album (name);
CREATE INDEX album_pageindex ON album (page);

CREATE INDEX album_amazon_asin_asin ON album_amazon_asin (asin);

CREATE INDEX albumjoin_albumindex ON albumjoin (album);
CREATE UNIQUE INDEX albumjoin_albumtrack ON albumjoin (album, track);
CREATE INDEX albumjoin_trackindex ON albumjoin (track);

CREATE INDEX albumwords_albumidindex ON albumwords (albumid);

CREATE UNIQUE INDEX artist_gidindex ON artist (gid);
CREATE UNIQUE INDEX artist_nameindex ON artist (name);
CREATE INDEX artist_pageindex ON artist (page);
CREATE INDEX artist_sortnameindex ON artist (sortname);

CREATE INDEX artist_relation_artist ON artist_relation (artist);
CREATE INDEX artist_relation_ref ON artist_relation (ref);

CREATE UNIQUE INDEX artistalias_nameindex ON artistalias (name);
CREATE INDEX artistalias_refindex ON artistalias (ref);

CREATE INDEX artistwords_artistidindex ON artistwords (artistid);

CREATE UNIQUE INDEX clientversion_version ON clientversion (version);

CREATE UNIQUE INDEX country_isocode ON country (isocode);
CREATE UNIQUE INDEX country_name ON country (name);

CREATE INDEX currentstat_name ON currentstat (name);

CREATE INDEX discid_albumindex ON discid (album);
CREATE UNIQUE INDEX discid_disc_key ON discid (disc);

CREATE INDEX historicalstat_date ON historicalstat (snapshotdate);
CREATE INDEX historicalstat_name_snapshotdate ON historicalstat (name, snapshotdate);

CREATE INDEX moderation_closed_idx_artist ON moderation_closed (artist);
CREATE INDEX moderation_closed_idx_expiretime ON moderation_closed (expiretime);
CREATE INDEX moderation_closed_idx_moderator ON moderation_closed (moderator);
CREATE INDEX moderation_closed_idx_rowid ON moderation_closed (rowid);
CREATE INDEX moderation_closed_idx_status ON moderation_closed (status);

CREATE INDEX moderation_note_closed_idx_moderation ON moderation_note_closed (moderation);

CREATE INDEX moderation_note_open_idx_moderation ON moderation_note_open (moderation);

CREATE INDEX moderation_open_idx_artist ON moderation_open (artist);
CREATE INDEX moderation_open_idx_expiretime ON moderation_open (expiretime);
CREATE INDEX moderation_open_idx_moderator ON moderation_open (moderator);
CREATE INDEX moderation_open_idx_rowid ON moderation_open (rowid);
CREATE INDEX moderation_open_idx_status ON moderation_open (status);

CREATE UNIQUE INDEX moderator_nameindex ON moderator (name);

CREATE UNIQUE INDEX moderator_preference_moderator_key ON moderator_preference (moderator, name);

CREATE UNIQUE INDEX moderator_subscribe_artist_moderator_key ON moderator_subscribe_artist (moderator, artist);

CREATE INDEX release_album ON release (album);

CREATE UNIQUE INDEX stats_timestampindex ON stats (timestamp);

CREATE INDEX toc_albumindex ON toc (album);
CREATE UNIQUE INDEX toc_discindex ON toc (discid);

CREATE INDEX track_artistindex ON track (artist);
CREATE UNIQUE INDEX track_gidindex ON track (gid);
CREATE INDEX track_nameindex ON track (name);

CREATE INDEX trackwords_trackidindex ON trackwords (trackid);

CREATE UNIQUE INDEX trm_trmindex ON trm (trm);

CREATE INDEX trmjoin_trackindex ON trmjoin (track);
CREATE INDEX trmjoin_trmindex ON trmjoin (trm);
CREATE UNIQUE INDEX trmjoin_trmtrack ON trmjoin (trm, track);

CREATE INDEX vote_closed_idx_moderation ON vote_closed (moderation);
CREATE INDEX vote_closed_idx_moderator ON vote_closed (moderator);

CREATE INDEX vote_open_idx_moderation ON vote_open (moderation);
CREATE INDEX vote_open_idx_moderator ON vote_open (moderator);

CREATE UNIQUE INDEX wordlist_wordindex ON wordlist (word);

-- vi: set ts=4 sw=4 et :
