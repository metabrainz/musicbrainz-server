\unset ON_ERROR_STOP

-- Alphabetical order by table

ALTER TABLE album DROP CONSTRAINT album_fk_artist;
ALTER TABLE album_amazon_asin DROP CONSTRAINT album_amazon_asin_fk_album;
ALTER TABLE album_cdtoc DROP CONSTRAINT album_cdtoc_fk_album;
ALTER TABLE album_cdtoc DROP CONSTRAINT album_cdtoc_fk_cdtoc;
ALTER TABLE albumjoin DROP CONSTRAINT albumjoin_fk_album;
ALTER TABLE albumjoin DROP CONSTRAINT albumjoin_fk_track;
-- albummeta ?
ALTER TABLE artist_relation DROP CONSTRAINT artist_relation_fk_artist1;
ALTER TABLE artist_relation DROP CONSTRAINT artist_relation_fk_artist2;
ALTER TABLE artistalias DROP CONSTRAINT artistalias_fk_ref;
ALTER TABLE automod_election DROP CONSTRAINT automod_election_fk_candidate;
ALTER TABLE automod_election DROP CONSTRAINT automod_election_fk_proposer;
ALTER TABLE automod_election DROP CONSTRAINT automod_election_fk_seconder_1;
ALTER TABLE automod_election DROP CONSTRAINT automod_election_fk_seconder_2;
ALTER TABLE automod_election_vote DROP CONSTRAINT automod_election_vote_fk_automod_election;
ALTER TABLE automod_election_vote DROP CONSTRAINT automod_election_vote_fk_voter;
ALTER TABLE moderation_closed DROP CONSTRAINT moderation_closed_fk_artist;
ALTER TABLE moderation_closed DROP CONSTRAINT moderation_closed_fk_moderator;
ALTER TABLE moderation_note_closed DROP CONSTRAINT moderation_note_closed_fk_moderation;
ALTER TABLE moderation_note_closed DROP CONSTRAINT moderation_note_closed_fk_moderator;
ALTER TABLE moderation_note_open DROP CONSTRAINT moderation_note_open_fk_moderation;
ALTER TABLE moderation_note_open DROP CONSTRAINT moderation_note_open_fk_moderator;
ALTER TABLE moderation_open DROP CONSTRAINT moderation_open_fk_artist;
ALTER TABLE moderation_open DROP CONSTRAINT moderation_open_fk_moderator;
ALTER TABLE moderator_preference DROP CONSTRAINT moderator_preference_fk_moderator;
ALTER TABLE moderator_subscribe_artist DROP CONSTRAINT modsubartist_fk_moderator;
ALTER TABLE release DROP CONSTRAINT release_fk_album;
ALTER TABLE release DROP CONSTRAINT release_fk_country;
ALTER TABLE track DROP CONSTRAINT track_fk_artist;
ALTER TABLE trm DROP CONSTRAINT trm_fk_clientversion;
ALTER TABLE trm_stat DROP CONSTRAINT trm_stat_fk_trm;
ALTER TABLE trmjoin DROP CONSTRAINT trmjoin_fk_track;
ALTER TABLE trmjoin DROP CONSTRAINT trmjoin_fk_trm;
ALTER TABLE trmjoin_stat DROP CONSTRAINT trmjoin_stat_fk_trmjoin;
ALTER TABLE vote_closed DROP CONSTRAINT vote_closed_fk_moderation;
ALTER TABLE vote_closed DROP CONSTRAINT vote_closed_fk_moderator;
ALTER TABLE vote_open DROP CONSTRAINT vote_open_fk_moderation;
ALTER TABLE vote_open DROP CONSTRAINT vote_open_fk_moderator;

-- vi: set ts=4 sw=4 et :
