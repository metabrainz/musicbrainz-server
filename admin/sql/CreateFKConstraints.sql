\set ON_ERROR_STOP 1

-- Alphabetical order by table, then constraint

-- No BEGIN/COMMIT here.  Each FK is created in its own transaction;
-- this is mainly because if you're setting up a big database, it
-- could get really annoying if it takes a long time to create the FKs,
-- only for the last one to fail and the whole lot gets rolled back.
-- It should also be more efficient, of course.

ALTER TABLE album
    ADD CONSTRAINT album_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE album_amazon_asin
    ADD CONSTRAINT album_amazon_asin_fk_album
    FOREIGN KEY (album)
    REFERENCES album(id)
    ON DELETE CASCADE;

ALTER TABLE album_cdtoc
    ADD CONSTRAINT album_cdtoc_fk_album
    FOREIGN KEY (album)
    REFERENCES album(id);

ALTER TABLE album_cdtoc
    ADD CONSTRAINT album_cdtoc_fk_cdtoc
    FOREIGN KEY (cdtoc)
    REFERENCES cdtoc(id);

ALTER TABLE albumjoin
    ADD CONSTRAINT albumjoin_fk_album
    FOREIGN KEY (album)
    REFERENCES album(id);

ALTER TABLE albumjoin
    ADD CONSTRAINT albumjoin_fk_track
    FOREIGN KEY (track)
    REFERENCES track(id);

ALTER TABLE albumwords
    ADD CONSTRAINT albumwords_fk_albumid
    FOREIGN KEY (albumid)
    REFERENCES album (id)
    ON DELETE CASCADE;

ALTER TABLE artistalias
    ADD CONSTRAINT artistalias_fk_ref
    FOREIGN KEY (ref)
    REFERENCES artist(id);

ALTER TABLE artist_meta
    	ADD CONSTRAINT fk_artist_meta_artist
    	FOREIGN KEY (id)
    	REFERENCES artist(id);
    	
ALTER TABLE artist_relation
    ADD CONSTRAINT artist_relation_fk_artist1
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE artist_relation
    ADD CONSTRAINT artist_relation_fk_artist2
    FOREIGN KEY (ref)
    REFERENCES artist(id);

ALTER TABLE artist_tag
    ADD CONSTRAINT fk_artist_tag_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE artist_tag
    ADD CONSTRAINT fk_artist_tag_tag
    FOREIGN KEY (tag)
    REFERENCES tag(id);

ALTER TABLE artistwords
    ADD CONSTRAINT artistwords_fk_artistid
    FOREIGN KEY (artistid)
    REFERENCES artist (id)
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

ALTER TABLE label
    ADD CONSTRAINT label_fk_country
    FOREIGN KEY (country)
    REFERENCES country(id);

ALTER TABLE label_meta
    	ADD CONSTRAINT fk_label_meta_label
    	FOREIGN KEY (id)
    	REFERENCES label(id);
    	
ALTER TABLE labelalias
    ADD CONSTRAINT labelalias_fk_ref
    FOREIGN KEY (ref)
    REFERENCES label(id);

ALTER TABLE label_tag
    ADD CONSTRAINT fk_label_tag_track
    FOREIGN KEY (label)
    REFERENCES label(id);

ALTER TABLE label_tag
    ADD CONSTRAINT fk_label_tag_tag
    FOREIGN KEY (tag)
    REFERENCES tag(id);

ALTER TABLE labelwords
    ADD CONSTRAINT labelwords_fk_labelid
    FOREIGN KEY (labelid)
    REFERENCES label (id)
    ON DELETE CASCADE;

ALTER TABLE l_album_album
    ADD CONSTRAINT fk_l_album_album_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_album_album(id);

ALTER TABLE l_album_album
    ADD CONSTRAINT fk_l_album_album_link0
    FOREIGN KEY (link0)
    REFERENCES album(id);

ALTER TABLE l_album_album
    ADD CONSTRAINT fk_l_album_album_link1
    FOREIGN KEY (link1)
    REFERENCES album(id);

ALTER TABLE l_album_artist
    ADD CONSTRAINT fk_l_album_artist_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_album_artist(id);

ALTER TABLE l_album_artist
    ADD CONSTRAINT fk_l_album_artist_link0
    FOREIGN KEY (link0)
    REFERENCES album(id);

ALTER TABLE l_album_artist
    ADD CONSTRAINT fk_l_album_artist_link1
    FOREIGN KEY (link1)
    REFERENCES artist(id);

ALTER TABLE l_album_label
    ADD CONSTRAINT fk_l_album_label_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_album_label(id);

ALTER TABLE l_album_label
    ADD CONSTRAINT fk_l_album_label_link0
    FOREIGN KEY (link0)
    REFERENCES album(id);

ALTER TABLE l_album_label
    ADD CONSTRAINT fk_l_album_label_link1
    FOREIGN KEY (link1)
    REFERENCES label(id);

ALTER TABLE l_album_track
    ADD CONSTRAINT fk_l_album_track_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_album_track(id);

ALTER TABLE l_album_track
    ADD CONSTRAINT fk_l_album_track_link0
    FOREIGN KEY (link0)
    REFERENCES album(id);

ALTER TABLE l_album_track
    ADD CONSTRAINT fk_l_album_track_link1
    FOREIGN KEY (link1)
    REFERENCES track(id);

ALTER TABLE l_album_url
    ADD CONSTRAINT fk_l_album_url_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_album_url(id);

ALTER TABLE l_album_url
    ADD CONSTRAINT fk_l_album_url_link0
    FOREIGN KEY (link0)
    REFERENCES album(id);

ALTER TABLE l_album_url
    ADD CONSTRAINT fk_l_album_url_link1
    FOREIGN KEY (link1)
    REFERENCES url(id);

ALTER TABLE l_artist_artist
    ADD CONSTRAINT fk_l_artist_artist_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_artist_artist(id);

ALTER TABLE l_artist_artist
    ADD CONSTRAINT fk_l_artist_artist_link0
    FOREIGN KEY (link0)
    REFERENCES artist(id);

ALTER TABLE l_artist_artist
    ADD CONSTRAINT fk_l_artist_artist_link1
    FOREIGN KEY (link1)
    REFERENCES artist(id);

ALTER TABLE l_artist_label
    ADD CONSTRAINT fk_l_artist_label_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_artist_label(id);

ALTER TABLE l_artist_label
    ADD CONSTRAINT fk_l_artist_label_link0
    FOREIGN KEY (link0)
    REFERENCES artist(id);

ALTER TABLE l_artist_label
    ADD CONSTRAINT fk_l_artist_label_link1
    FOREIGN KEY (link1)
    REFERENCES label(id);

ALTER TABLE l_artist_track
    ADD CONSTRAINT fk_l_artist_track_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_artist_track(id);

ALTER TABLE l_artist_track
    ADD CONSTRAINT fk_l_artist_track_link0
    FOREIGN KEY (link0)
    REFERENCES artist(id);

ALTER TABLE l_artist_track
    ADD CONSTRAINT fk_l_artist_track_link1
    FOREIGN KEY (link1)
    REFERENCES track(id);

ALTER TABLE l_artist_url
    ADD CONSTRAINT fk_l_artist_url_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_artist_url(id);

ALTER TABLE l_artist_url
    ADD CONSTRAINT fk_l_artist_url_link0
    FOREIGN KEY (link0)
    REFERENCES artist(id);

ALTER TABLE l_artist_url
    ADD CONSTRAINT fk_l_artist_url_link1
    FOREIGN KEY (link1)
    REFERENCES url(id);

ALTER TABLE l_label_label
    ADD CONSTRAINT fk_l_label_label_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_label_label(id);

ALTER TABLE l_label_label
    ADD CONSTRAINT fk_l_label_label_link0
    FOREIGN KEY (link0)
    REFERENCES label(id);

ALTER TABLE l_label_label
    ADD CONSTRAINT fk_l_label_label_link1
    FOREIGN KEY (link1)
    REFERENCES label(id);

ALTER TABLE l_label_track
    ADD CONSTRAINT fk_l_label_track_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_label_track(id);

ALTER TABLE l_label_track
    ADD CONSTRAINT fk_l_label_track_link0
    FOREIGN KEY (link0)
    REFERENCES label(id);

ALTER TABLE l_label_track
    ADD CONSTRAINT fk_l_label_track_link1
    FOREIGN KEY (link1)
    REFERENCES track(id);

ALTER TABLE l_label_url
    ADD CONSTRAINT fk_l_label_url_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_label_url(id);

ALTER TABLE l_label_url
    ADD CONSTRAINT fk_l_label_url_link0
    FOREIGN KEY (link0)
    REFERENCES label(id);

ALTER TABLE l_label_url
    ADD CONSTRAINT fk_l_label_url_link1
    FOREIGN KEY (link1)
    REFERENCES url(id);

ALTER TABLE l_track_track
    ADD CONSTRAINT fk_l_track_track_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_track_track(id);

ALTER TABLE l_track_track
    ADD CONSTRAINT fk_l_track_track_link0
    FOREIGN KEY (link0)
    REFERENCES track(id);

ALTER TABLE l_track_track
    ADD CONSTRAINT fk_l_track_track_link1
    FOREIGN KEY (link1)
    REFERENCES track(id);

ALTER TABLE l_track_url
    ADD CONSTRAINT fk_l_track_url_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_track_url(id);

ALTER TABLE l_track_url
    ADD CONSTRAINT fk_l_track_url_link0
    FOREIGN KEY (link0)
    REFERENCES track(id);

ALTER TABLE l_track_url
    ADD CONSTRAINT fk_l_track_url_link1
    FOREIGN KEY (link1)
    REFERENCES url(id);

ALTER TABLE l_url_url
    ADD CONSTRAINT fk_l_url_url_link_type
    FOREIGN KEY (link_type)
    REFERENCES lt_url_url(id);

ALTER TABLE l_url_url
    ADD CONSTRAINT fk_l_url_url_link0
    FOREIGN KEY (link0)
    REFERENCES url(id);

ALTER TABLE l_url_url
    ADD CONSTRAINT fk_l_url_url_link1
    FOREIGN KEY (link1)
    REFERENCES url(id);

ALTER TABLE link_attribute
    ADD CONSTRAINT fk_link_attribute_type
    FOREIGN KEY (attribute_type)
    REFERENCES link_attribute_type(id);

ALTER TABLE lt_album_album
    ADD CONSTRAINT fk_lt_album_album_parent
    FOREIGN KEY (parent)
    REFERENCES lt_album_album(id);

ALTER TABLE lt_album_artist
    ADD CONSTRAINT fk_lt_album_artist_parent
    FOREIGN KEY (parent)
    REFERENCES lt_album_artist(id);

ALTER TABLE lt_album_label
    ADD CONSTRAINT fk_lt_album_label_parent
    FOREIGN KEY (parent)
    REFERENCES lt_album_label(id);

ALTER TABLE lt_album_track
    ADD CONSTRAINT fk_lt_album_track_parent
    FOREIGN KEY (parent)
    REFERENCES lt_album_track(id);

ALTER TABLE lt_album_url
    ADD CONSTRAINT fk_lt_album_url_parent
    FOREIGN KEY (parent)
    REFERENCES lt_album_url(id);

ALTER TABLE lt_artist_artist
    ADD CONSTRAINT fk_lt_artist_artist_parent
    FOREIGN KEY (parent)
    REFERENCES lt_artist_artist(id);

ALTER TABLE lt_artist_label
    ADD CONSTRAINT fk_lt_artist_label_parent
    FOREIGN KEY (parent)
    REFERENCES lt_artist_label(id);

ALTER TABLE lt_artist_track
    ADD CONSTRAINT fk_lt_artist_track_parent
    FOREIGN KEY (parent)
    REFERENCES lt_artist_track(id);

ALTER TABLE lt_artist_url
    ADD CONSTRAINT fk_lt_artist_url_parent
    FOREIGN KEY (parent)
    REFERENCES lt_artist_url(id);

ALTER TABLE lt_label_label
    ADD CONSTRAINT fk_lt_label_label_parent
    FOREIGN KEY (parent)
    REFERENCES lt_label_label(id);

ALTER TABLE lt_label_track
    ADD CONSTRAINT fk_lt_label_track_parent
    FOREIGN KEY (parent)
    REFERENCES lt_label_track(id);

ALTER TABLE lt_label_url
    ADD CONSTRAINT fk_lt_label_url_parent
    FOREIGN KEY (parent)
    REFERENCES lt_label_url(id);

ALTER TABLE lt_track_track
    ADD CONSTRAINT fk_lt_track_track_parent
    FOREIGN KEY (parent)
    REFERENCES lt_track_track(id);

ALTER TABLE lt_track_url
    ADD CONSTRAINT fk_lt_track_url_parent
    FOREIGN KEY (parent)
    REFERENCES lt_track_url(id);

ALTER TABLE lt_url_url
    ADD CONSTRAINT fk_lt_url_url_parent
    FOREIGN KEY (parent)
    REFERENCES lt_url_url(id);

ALTER TABLE moderation_closed
    ADD CONSTRAINT moderation_closed_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE moderation_closed
    ADD CONSTRAINT moderation_closed_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE moderation_closed
    ADD CONSTRAINT moderation_closed_fk_language
    FOREIGN KEY (language)
    REFERENCES language(id);

ALTER TABLE moderation_note_closed
    ADD CONSTRAINT moderation_note_closed_fk_moderation
    FOREIGN KEY (moderation)
    REFERENCES moderation_closed(id);

ALTER TABLE moderation_note_closed
    ADD CONSTRAINT moderation_note_closed_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE moderation_open
    ADD CONSTRAINT moderation_open_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE moderation_open
    ADD CONSTRAINT moderation_open_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE moderation_open
    ADD CONSTRAINT moderation_open_fk_language
    FOREIGN KEY (language)
    REFERENCES language(id);

ALTER TABLE moderation_note_open
    ADD CONSTRAINT moderation_note_open_fk_moderation
    FOREIGN KEY (moderation)
    REFERENCES moderation_open(id);

ALTER TABLE moderation_note_open
    ADD CONSTRAINT moderation_note_open_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE moderator_preference
    ADD CONSTRAINT moderator_preference_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE moderator_subscribe_artist
    ADD CONSTRAINT modsubartist_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE moderator_subscribe_label
    ADD CONSTRAINT modsublabel_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE editor_subscribe_editor
    ADD CONSTRAINT editsubeditor_fk_moderator
    FOREIGN KEY (editor)
    REFERENCES moderator(id);

ALTER TABLE editor_subscribe_editor
    ADD CONSTRAINT editsubeditor_fk_moderator2
    FOREIGN KEY (subscribededitor)
    REFERENCES moderator(id);

ALTER TABLE "PendingData"
    ADD CONSTRAINT "PendingData_SeqId"
    FOREIGN KEY ("SeqId")
    REFERENCES "Pending" ("SeqId")
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE puid
    ADD CONSTRAINT puid_fk_clientversion
    FOREIGN KEY (version)
    REFERENCES clientversion(id);

ALTER TABLE puidjoin
    ADD CONSTRAINT puidjoin_fk_track
    FOREIGN KEY (track)
    REFERENCES track(id);

ALTER TABLE puidjoin
    ADD CONSTRAINT puidjoin_fk_puid
    FOREIGN KEY (puid)
    REFERENCES puid(id);

ALTER TABLE puidjoin_stat
    ADD CONSTRAINT puidjoin_stat_fk_puidjoin
    FOREIGN KEY (puidjoin_id)
    REFERENCES puidjoin(id)
    ON DELETE CASCADE;

ALTER TABLE puid_stat
    ADD CONSTRAINT puid_stat_fk_puid
    FOREIGN KEY (puid_id)
    REFERENCES puid(id)
    ON DELETE CASCADE;

ALTER TABLE release
    ADD CONSTRAINT release_fk_album
    FOREIGN KEY (album)
    REFERENCES album(id);

ALTER TABLE release
    ADD CONSTRAINT release_fk_country
    FOREIGN KEY (country)
    REFERENCES country(id);

ALTER TABLE release
    ADD CONSTRAINT release_fk_label
    FOREIGN KEY (label)
    REFERENCES label(id);

ALTER TABLE release_tag
    ADD CONSTRAINT fk_release_tag_release
    FOREIGN KEY (release)
    REFERENCES album(id);

ALTER TABLE release_tag
    ADD CONSTRAINT fk_release_tag_tag
    FOREIGN KEY (tag)
    REFERENCES tag(id);

ALTER TABLE tag_relation
    ADD CONSTRAINT tag_relation_fk_tag1
    FOREIGN KEY (tag1)
    REFERENCES tag(id)
    ON DELETE CASCADE;

ALTER TABLE tag_relation
    ADD CONSTRAINT tag_relation_fk_tag2
    FOREIGN KEY (tag2)
    REFERENCES tag(id)
    ON DELETE CASCADE;

ALTER TABLE track
    ADD CONSTRAINT track_fk_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE track_meta
    	ADD CONSTRAINT fk_track_meta_track
    	FOREIGN KEY (id)
    	REFERENCES track(id);
    	
ALTER TABLE track_tag
    ADD CONSTRAINT fk_track_tag_track
    FOREIGN KEY (track)
    REFERENCES track(id);

ALTER TABLE track_tag
    ADD CONSTRAINT fk_track_tag_tag
    FOREIGN KEY (tag)
    REFERENCES tag(id);

ALTER TABLE trackwords
    ADD CONSTRAINT trackwords_fk_trackid
    FOREIGN KEY (trackid)
    REFERENCES track (id)
    ON DELETE CASCADE;

ALTER TABLE vote_closed
    ADD CONSTRAINT vote_closed_fk_moderation
    FOREIGN KEY (moderation)
    REFERENCES moderation_closed(id);

ALTER TABLE vote_closed
    ADD CONSTRAINT vote_closed_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE vote_open
    ADD CONSTRAINT vote_open_fk_moderation
    FOREIGN KEY (moderation)
    REFERENCES moderation_open(id);

ALTER TABLE vote_open
    ADD CONSTRAINT vote_open_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE album
    ADD CONSTRAINT album_fk_language
    FOREIGN KEY (language)
    REFERENCES language(id);

ALTER TABLE album
    ADD CONSTRAINT album_fk_script
    FOREIGN KEY (script)
    REFERENCES script(id);

ALTER TABLE script_language
    ADD CONSTRAINT script_language_fk_language
    FOREIGN KEY (language)
    REFERENCES language(id);

ALTER TABLE script_language
    ADD CONSTRAINT script_language_fk_script
    FOREIGN KEY (script)
    REFERENCES script(id);

-- vi: set ts=4 sw=4 et :
