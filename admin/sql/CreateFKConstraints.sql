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

ALTER TABLE moderation
    ADD CONSTRAINT moderation_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE moderation
    ADD CONSTRAINT moderation_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE votes
    ADD CONSTRAINT votes_fk_moderator
    FOREIGN KEY (uid)
    REFERENCES moderator(id);

ALTER TABLE votes
    ADD CONSTRAINT votes_fk_moderation
    FOREIGN KEY (rowid)
    REFERENCES moderation(id);

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
-- moderationnote ?

