
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

ALTER TABLE moderation_open
    DROP CONSTRAINT moderation_open_fk_artist;

ALTER TABLE moderation_open
    DROP CONSTRAINT moderation_open_fk_moderator;

ALTER TABLE moderation_note_open
    DROP CONSTRAINT moderation_note_open_fk_moderation;

ALTER TABLE moderation_note_open
    DROP CONSTRAINT moderation_note_open_fk_moderator;

ALTER TABLE vote_open
    DROP CONSTRAINT vote_open_fk_moderator;

ALTER TABLE vote_open
    DROP CONSTRAINT vote_open_fk_moderation;

ALTER TABLE moderation_closed
    DROP CONSTRAINT moderation_closed_fk_artist;

ALTER TABLE moderation_closed
    DROP CONSTRAINT moderation_closed_fk_moderator;

ALTER TABLE moderation_note_closed
    DROP CONSTRAINT moderation_note_closed_fk_moderation;

ALTER TABLE moderation_note_closed
    DROP CONSTRAINT moderation_note_closed_fk_moderator;

ALTER TABLE vote_closed
    DROP CONSTRAINT vote_closed_fk_moderator;

ALTER TABLE vote_closed
    DROP CONSTRAINT vote_closed_fk_moderation;

ALTER TABLE artist_relation
    DROP CONSTRAINT artist_relation_fk_artist1;

ALTER TABLE artist_relation
    DROP CONSTRAINT artist_relation_fk_artist2;

ALTER TABLE moderator_preference
    DROP CONSTRAINT moderator_preference_fk_moderator;

ALTER TABLE moderator_subscribe_artist
    DROP CONSTRAINT modsubartist_fk_moderator;

-- albummeta ?
-- moderationnote ?

ALTER TABLE release
    DROP CONSTRAINT release_fk_album;

ALTER TABLE release
    DROP CONSTRAINT release_fk_country;

ALTER TABLE album_amazon_asin
    DROP CONSTRAINT album_amazon_asin_fk_album;

-- vi: set ts=4 sw=4 et :
