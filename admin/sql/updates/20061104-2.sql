-- Abstract: Labels & catalog numbers
--           Part 2: Foreign constraints

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE labelwords
    ADD CONSTRAINT labelwords_fk_labelid
    FOREIGN KEY (labelid)
    REFERENCES label (id)
    ON DELETE CASCADE;

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

ALTER TABLE lt_album_label
    ADD CONSTRAINT fk_lt_album_label_parent
    FOREIGN KEY (parent)
    REFERENCES lt_album_label(id);

ALTER TABLE lt_artist_label
    ADD CONSTRAINT fk_lt_artist_label_parent
    FOREIGN KEY (parent)
    REFERENCES lt_artist_label(id);

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

ALTER TABLE labelalias
    ADD CONSTRAINT labelalias_fk_ref
    FOREIGN KEY (ref)
    REFERENCES label(id);

ALTER TABLE label
    ADD CONSTRAINT label_fk_country
    FOREIGN KEY (country)
    REFERENCES country(id);

ALTER TABLE moderator_subscribe_label
    ADD CONSTRAINT modsublabel_fk_moderator
    FOREIGN KEY (moderator)
    REFERENCES moderator(id);

ALTER TABLE release
    ADD CONSTRAINT release_fk_label
    FOREIGN KEY (label)
    REFERENCES label(id);

COMMIT;

-- vi: set ts=4 sw=4 et :
