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

ALTER TABLE album_cdtoc
    ADD CONSTRAINT album_cdtoc_fk_album
    FOREIGN KEY (album)
    REFERENCES album(id);

ALTER TABLE album_cdtoc
    ADD CONSTRAINT album_cdtoc_fk_cdtoc
    FOREIGN KEY (cdtoc)
    REFERENCES cdtoc(id);

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
    REFERENCES album(id)
    ON DELETE CASCADE;

ALTER TABLE automod_election
    ADD CONSTRAINT automod_election_fk_candidate
    FOREIGN KEY (candidate)
    REFERENCES moderator(id);

ALTER TABLE automod_election
    ADD CONSTRAINT automod_election_fk_proposer
    FOREIGN KEY (proposer)
    REFERENCES moderator(id);

ALTER TABLE automod_election
    ADD CONSTRAINT automod_election_fk_seconder_1
    FOREIGN KEY (seconder_1)
    REFERENCES moderator(id);

ALTER TABLE automod_election
    ADD CONSTRAINT automod_election_fk_seconder_2
    FOREIGN KEY (seconder_2)
    REFERENCES moderator(id);

ALTER TABLE automod_election_vote
    ADD CONSTRAINT automod_election_vote_fk_automod_election
    FOREIGN KEY (automod_election)
    REFERENCES automod_election(id);

ALTER TABLE automod_election_vote
    ADD CONSTRAINT automod_election_vote_fk_voter
    FOREIGN KEY (voter)
    REFERENCES moderator(id);

-- vi: set ts=4 sw=4 et :
