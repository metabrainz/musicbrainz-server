\set ON_ERROR_STOP 1

-- No BEGIN/COMMIT here.  Each index is created in its own transaction;
-- this is mainly because if you're setting up a big database, it
-- could get really annoying if it takes a long time to create the indexes,
-- only for the last one to fail and the whole lot gets rolled back.
-- It should also be more efficient, of course.

-- Alphabetical order by table

CREATE INDEX album_artistindex ON album (artist);
CREATE UNIQUE INDEX album_gidindex ON album (gid);
CREATE INDEX album_nameindex ON album (name);
CREATE INDEX album_pageindex ON album (page);

CREATE INDEX album_amazon_asin_asin ON album_amazon_asin (asin);

CREATE UNIQUE INDEX album_cdtoc_albumcdtoc ON album_cdtoc (album, cdtoc);

CREATE INDEX albumjoin_albumindex ON albumjoin (album);
CREATE UNIQUE INDEX albumjoin_albumtrack ON albumjoin (album, track);
CREATE INDEX albumjoin_trackindex ON albumjoin (track);

CREATE INDEX albumwords_albumidindex ON albumwords (albumid);

CREATE INDEX annotation_rowidindex ON annotation (rowid);
CREATE UNIQUE INDEX annotation_moderationindex ON annotation (moderation);

CREATE UNIQUE INDEX artist_gidindex ON artist (gid);
CREATE INDEX artist_nameindex ON artist (name);
CREATE INDEX artist_pageindex ON artist (page);
CREATE INDEX artist_sortnameindex ON artist (sortname);

CREATE INDEX artist_relation_artist ON artist_relation (artist);
CREATE INDEX artist_relation_ref ON artist_relation (ref);

CREATE UNIQUE INDEX artistalias_nameindex ON artistalias (name);
CREATE INDEX artistalias_refindex ON artistalias (ref);

CREATE INDEX artistwords_artistidindex ON artistwords (artistid);

CREATE INDEX cdtoc_discid ON cdtoc (discid);
CREATE INDEX cdtoc_freedbid ON cdtoc (freedbid);
CREATE UNIQUE INDEX cdtoc_toc ON cdtoc (trackcount, leadoutoffset, trackoffset);

CREATE UNIQUE INDEX clientversion_version ON clientversion (version);

CREATE UNIQUE INDEX country_isocode ON country (isocode);
CREATE UNIQUE INDEX country_name ON country (name);

CREATE INDEX currentstat_name ON currentstat (name);

CREATE INDEX historicalstat_date ON historicalstat (snapshotdate);
CREATE INDEX historicalstat_name_snapshotdate ON historicalstat (name, snapshotdate);

CREATE UNIQUE INDEX l_album_album_idx_uniq ON l_album_album (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_album_artist_idx_uniq ON l_album_artist (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_album_track_idx_uniq ON l_album_track (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_album_url_idx_uniq ON l_album_url (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_artist_artist_idx_uniq ON l_artist_artist (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_artist_track_idx_uniq ON l_artist_track (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_artist_url_idx_uniq ON l_artist_url (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_track_track_idx_uniq ON l_track_track (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_track_url_idx_uniq ON l_track_url (link0, link1, link_type, begindate, enddate);
CREATE UNIQUE INDEX l_url_url_idx_uniq ON l_url_url (link0, link1, link_type, begindate, enddate);

CREATE INDEX link_attribute_idx_link_type ON link_attribute (link, link_type);
CREATE UNIQUE INDEX link_attribute_type_idx_parent_name ON link_attribute_type (parent, name);
CREATE INDEX link_attribute_type_idx_name ON link_attribute_type (name);

CREATE UNIQUE INDEX lt_album_album_idx_mbid ON lt_album_album (mbid);
CREATE UNIQUE INDEX lt_album_album_idx_parent_name ON lt_album_album (parent, name);
CREATE UNIQUE INDEX lt_album_artist_idx_mbid ON lt_album_artist (mbid);
CREATE UNIQUE INDEX lt_album_artist_idx_parent_name ON lt_album_artist (parent, name);
CREATE UNIQUE INDEX lt_album_track_idx_mbid ON lt_album_track (mbid);
CREATE UNIQUE INDEX lt_album_track_idx_parent_name ON lt_album_track (parent, name);
CREATE UNIQUE INDEX lt_album_url_idx_mbid ON lt_album_url (mbid);
CREATE UNIQUE INDEX lt_album_url_idx_parent_name ON lt_album_url (parent, name);
CREATE UNIQUE INDEX lt_artist_artist_idx_mbid ON lt_artist_artist (mbid);
CREATE UNIQUE INDEX lt_artist_artist_idx_parent_name ON lt_artist_artist (parent, name);
CREATE UNIQUE INDEX lt_artist_track_idx_mbid ON lt_artist_track (mbid);
CREATE UNIQUE INDEX lt_artist_track_idx_parent_name ON lt_artist_track (parent, name);
CREATE UNIQUE INDEX lt_artist_url_idx_mbid ON lt_artist_url (mbid);
CREATE UNIQUE INDEX lt_artist_url_idx_parent_name ON lt_artist_url (parent, name);
CREATE UNIQUE INDEX lt_track_track_idx_mbid ON lt_track_track (mbid);
CREATE UNIQUE INDEX lt_track_track_idx_parent_name ON lt_track_track (parent, name);
CREATE UNIQUE INDEX lt_track_url_idx_mbid ON lt_track_url (mbid);
CREATE UNIQUE INDEX lt_track_url_idx_parent_name ON lt_track_url (parent, name);
CREATE UNIQUE INDEX lt_url_url_idx_mbid ON lt_url_url (mbid);
CREATE UNIQUE INDEX lt_url_url_idx_parent_name ON lt_url_url (parent, name);

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

CREATE INDEX "Pending_XID_Index" ON "Pending" ("XID");

CREATE INDEX release_album ON release (album);

CREATE UNIQUE INDEX stats_timestampindex ON stats (timestamp);

CREATE INDEX track_artistindex ON track (artist);
CREATE UNIQUE INDEX track_gidindex ON track (gid);
CREATE INDEX track_nameindex ON track (name);

CREATE INDEX trackwords_trackidindex ON trackwords (trackid);

CREATE UNIQUE INDEX trm_trmindex ON trm (trm);

CREATE UNIQUE INDEX trm_stat_trm_idindex ON trm_stat (trm_id, month_id);

CREATE INDEX trmjoin_trackindex ON trmjoin (track);
CREATE UNIQUE INDEX trmjoin_trmtrack ON trmjoin (trm, track);

CREATE UNIQUE INDEX trmjoin_stat_trmjoin_idindex ON trmjoin_stat (trmjoin_id, month_id);

CREATE UNIQUE INDEX url_idx_gid ON url (gid);

CREATE INDEX vote_closed_idx_moderation ON vote_closed (moderation);
CREATE INDEX vote_closed_idx_moderator ON vote_closed (moderator);

CREATE INDEX vote_open_idx_moderation ON vote_open (moderation);
CREATE INDEX vote_open_idx_moderator ON vote_open (moderator);

CREATE UNIQUE INDEX wordlist_wordindex ON wordlist (word);

-- vi: set ts=4 sw=4 et :
