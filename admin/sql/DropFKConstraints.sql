
ALTER TABLE artistalias
    DROP CONSTRAINT artistalias_fk_ref;

ALTER TABLE album
    DROP CONSTRAINT album_fk_artist;

ALTER TABLE track
    DROP CONSTRAINT track_fk_artist;

ALTER TABLE albumjoin
    DROP CONSTRAINT albumjoin_fk_album;

ALTER TABLE albumjoin
    DROP CONSTRAINT albumjoin_fk_track;

ALTER TABLE trm
    DROP CONSTRAINT trm_fk_clientversion;

ALTER TABLE trmjoin
    DROP CONSTRAINT trmjoin_fk_trm;

ALTER TABLE trmjoin
    DROP CONSTRAINT trmjoin_fk_track;

ALTER TABLE discid
    DROP CONSTRAINT discid_fk_album;

ALTER TABLE toc
    DROP CONSTRAINT toc_fk_album;

ALTER TABLE toc
    DROP CONSTRAINT toc_fk_discid;

ALTER TABLE moderation
    DROP CONSTRAINT moderation_fk_artist;

ALTER TABLE moderation
    DROP CONSTRAINT moderation_fk_moderator;

ALTER TABLE moderationnote
    DROP CONSTRAINT moderationnote_fk_moderation;

ALTER TABLE moderationnote
    DROP CONSTRAINT moderationnote_fk_moderator;

ALTER TABLE votes
    DROP CONSTRAINT votes_fk_moderator;

ALTER TABLE votes
    DROP CONSTRAINT votes_fk_moderation;

ALTER TABLE artist_relation
    DROP CONSTRAINT artist_relation_fk_artist1;

ALTER TABLE artist_relation
    DROP CONSTRAINT artist_relation_fk_artist2;

ALTER TABLE moderator_preference_fk_moderator
    DROP CONSTRAINT moderator_preference_fk_moderator;

ALTER TABLE moderator_subscribe_artist
    DROP CONSTRAINT modsubartist_fk_moderator;

-- albummeta ?
-- moderationnote ?

ALTER TABLE release
    DROP CONSTRAINT release_fk_album;

ALTER TABLE release
    DROP CONSTRAINT release_fk_country;

-- vi: set ts=4 sw=4 et :
