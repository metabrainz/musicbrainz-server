\set ON_ERROR_STOP 1

ALTER TABLE artistalias
    ADD CONSTRAINT artistalias_fk_ref
    FOREIGN KEY (ref)
    REFERENCES artist(id);

ALTER TABLE album
    ADD CONSTRAINT album_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE track
    ADD CONSTRAINT track_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE albumjoin
    ADD CONSTRAINT albumjoin_fk_album
    FOREIGN KEY (album)
    REFERENCES album(id);

ALTER TABLE albumjoin
    ADD CONSTRAINT albumjoin_fk_track
    FOREIGN KEY (track)
    REFERENCES track(id);

ALTER TABLE trm
    ADD CONSTRAINT trm_fk_clientversion
    FOREIGN KEY (version)
    REFERENCES clientversion(id);

ALTER TABLE trmjoin
    ADD CONSTRAINT trmjoin_fk_trm
    FOREIGN KEY (trm)
    REFERENCES trm(id);

ALTER TABLE trmjoin
    ADD CONSTRAINT trmjoin_fk_track
    FOREIGN KEY (track)
    REFERENCES track(id);

ALTER TABLE discid
    ADD CONSTRAINT discid_fk_album
    FOREIGN KEY (album)
    REFERENCES album(id);

ALTER TABLE toc
    ADD CONSTRAINT toc_fk_album
    FOREIGN KEY (album)
    REFERENCES album(id);

ALTER TABLE toc
    ADD CONSTRAINT toc_fk_discid
    FOREIGN KEY (discid)
    REFERENCES discid(disc);

ALTER TABLE moderation_open
    ADD CONSTRAINT moderation_open_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE moderation_open
    ADD CONSTRAINT moderation_open_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE moderation_note_open
    ADD CONSTRAINT moderation_note_open_fk_moderation
    FOREIGN KEY (moderation)
    REFERENCES moderation_open(id);

ALTER TABLE moderation_note_open
    ADD CONSTRAINT moderation_note_open_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE vote_open
    ADD CONSTRAINT vote_open_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE vote_open
    ADD CONSTRAINT vote_open_fk_moderation
    FOREIGN KEY (moderation)
    REFERENCES moderation_open(id);

ALTER TABLE moderation_closed
    ADD CONSTRAINT moderation_closed_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE moderation_closed
    ADD CONSTRAINT moderation_closed_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE moderation_note_closed
    ADD CONSTRAINT moderation_note_closed_fk_moderation
    FOREIGN KEY (moderation)
    REFERENCES moderation_closed(id);

ALTER TABLE moderation_note_closed
    ADD CONSTRAINT moderation_note_closed_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE vote_closed
    ADD CONSTRAINT vote_closed_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE vote_closed
    ADD CONSTRAINT vote_closed_fk_moderation
    FOREIGN KEY (moderation)
    REFERENCES moderation_closed(id);

ALTER TABLE artist_relation
    ADD CONSTRAINT artist_relation_fk_artist1
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE artist_relation
    ADD CONSTRAINT artist_relation_fk_artist2
    FOREIGN KEY (ref)
    REFERENCES artist(id);

ALTER TABLE moderator_preference
    ADD CONSTRAINT moderator_preference_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE moderator_subscribe_artist
    ADD CONSTRAINT modsubartist_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

-- albummeta ?

ALTER TABLE release
    ADD CONSTRAINT release_fk_album
    FOREIGN KEY (album)
    REFERENCES album(id);

ALTER TABLE release
    ADD CONSTRAINT release_fk_country
    FOREIGN KEY (country)
    REFERENCES country(id);

ALTER TABLE album_amazon_asin
    ADD CONSTRAINT album_amazon_asin_fk_album
    FOREIGN KEY (album)
    REFERENCES album(id);

-- vi: set ts=4 sw=4 et :
