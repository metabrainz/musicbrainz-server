BEGIN;

------------------------
-- Misc
------------------------

INSERT INTO country SELECT * FROM public.country;
INSERT INTO language SELECT * FROM public.language;
INSERT INTO script SELECT * FROM public.script;
INSERT INTO script_language SELECT * FROM public.script_language;

INSERT INTO gender (id, name) VALUES
    (1, 'Male'),
    (2, 'Female');

INSERT INTO artist_type (id, name) VALUES
    (1, 'Person'),
    (2, 'Group');

INSERT INTO label_type (id, name) VALUES
    (1, 'Distributor'),
    (2, 'Holding'),
    (3, 'Production'),
    (4, 'Original Production'),
    (5, 'Bootleg Production'),
    (6, 'Reissue Production'),
    (7, 'Publisher');

INSERT INTO release_status (id, name) VALUES
    (1, 'Official'),
    (2, 'Promotion'),
    (3, 'Bootleg'),
    (4, 'Pseudo-Release');

INSERT INTO release_packaging (id, name) VALUES
    (1, 'Jewel Case'),
    (2, 'Slim Jewel Case'),
    (3, 'Digipak'),
    (4, 'Paper Sleeve'),
    (5, 'Other');

INSERT INTO release_group_type (id, name) VALUES
    (1, 'Non-Album Tracks'),
    (2, 'Album'),
    (3, 'Single'),
    (4, 'EP'),
    (5, 'Compilation'),
    (6, 'Soundtrack'),
    (7, 'Spokenword'),
    (8, 'Interview'),
    (9, 'Audiobook'),
    (10, 'Live'),
    (11, 'Remix'),
    (12, 'Other');

INSERT INTO medium_format (id, name, year) VALUES
    (1, 'CD', 1982),
    (2, 'DVD', 1995),
    (3, 'SACD', 1999),
    (4, 'DualDisc', 2004),
    (5, 'LaserDisc', 1978),
    (6, 'MiniDisc', 1992),
    (7, 'Vinyl', 1895),
    (8, 'Cassette', 1964),
    (9, 'Cartridge', 1962),
    (10, 'Reel-to-reel', 1935),
    (11, 'DAT', 1976),
    (12, 'Digital Media', NULL),
    (13, 'Other', NULL),
    (14, 'Wax Cylinder', 1877),
    (15, 'Piano Roll', 1883);

INSERT INTO url (id, gid, url, description, refcount)
    SELECT id, gid::uuid, url, description, refcount FROM public.url;

INSERT INTO replication_control SELECT * FROM public.replication_control;
INSERT INTO currentstat SELECT * FROM public.currentstat;
INSERT INTO historicalstat SELECT * FROM public.historicalstat;

------------------------
-- Tags
------------------------

INSERT INTO tag SELECT * FROM public.tag;
INSERT INTO tag_relation SELECT * FROM public.tag_relation;

INSERT INTO artist_tag SELECT * FROM public.artist_tag;
INSERT INTO label_tag SELECT * FROM public.label_tag;
INSERT INTO recording_tag SELECT * FROM public.track_tag;

------------------------
-- Release groups
------------------------

INSERT INTO release_name (name)
    (SELECT DISTINCT name FROM public.album) UNION
    (SELECT DISTINCT name FROM public.release_group);

CREATE UNIQUE INDEX tmp_release_name_name_idx ON release_name (name);

INSERT INTO release_group (id, gid, name, type, artist_credit)
    SELECT
        a.id, gid::uuid, n.id,
        CASE
            WHEN 0 = type THEN 1
            WHEN 1 = type THEN 2
            WHEN 2 = type THEN 3
            WHEN 3 = type THEN 4
            WHEN 4 = type THEN 5
            WHEN 5 = type THEN 6
            WHEN 6 = type THEN 7
            WHEN 7 = type THEN 8
            WHEN 8 = type THEN 9
            WHEN 9 = type THEN 10
            WHEN 10 = type THEN 11
            WHEN 11 = type THEN 12
            ELSE NULL
        END, artist
    FROM public.release_group a JOIN release_name n ON a.name = n.name;

------------------------
-- Releases
------------------------

-- Check which release events should get album GIDs (the earliest one from an album)
SELECT gid::uuid, a.id AS album, (SELECT min(id) FROM public.release r WHERE a.id=r.album) AS id
    INTO TEMPORARY tmp_release_gid
    FROM public.album a
    WHERE EXISTS (SELECT id FROM public.release r WHERE r.album=a.id);

CREATE UNIQUE INDEX tmp_release_gid_id ON tmp_release_gid(id);
CREATE UNIQUE INDEX tmp_release_gid_album ON tmp_release_gid(album);

INSERT INTO release
    (id, gid, release_group, name, artist_credit, barcode, status,
     date_year, date_month, date_day, country, language, script)
    SELECT
        r.id,
        CASE WHEN g.gid IS NULL THEN
            generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/release/?id=' || r.id)
        ELSE g.gid END,
        a.release_group,
        n.id,
        a.artist,
        r.barcode,
        CASE
            WHEN 100 = ANY(a.attributes[2:10]) THEN 1
            WHEN 101 = ANY(a.attributes[2:10]) THEN 2
            WHEN 102 = ANY(a.attributes[2:10]) THEN 3
            WHEN 103 = ANY(a.attributes[2:10]) THEN 4
            ELSE NULL
        END,
        NULLIF(substr(releasedate, 1, 4)::int, 0),
        NULLIF(substr(releasedate, 6, 2)::int, 0),
        NULLIF(substr(releasedate, 9, 2)::int, 0),
        country,
        language,
        script
    FROM public.release r
        JOIN public.album a ON r.album = a.id
        JOIN release_name n ON a.name = n.name
        LEFT JOIN tmp_release_gid g ON r.id=g.id;

SELECT SETVAL('release_id_seq', (SELECT MAX(id) FROM release));

-- Generate release IDs for albums without release events
SELECT nextval('release_id_seq') AS id, id AS album
    INTO TEMPORARY tmp_new_release
    FROM public.album a
    WHERE NOT EXISTS (SELECT id FROM public.release r WHERE r.album=a.id);

CREATE TABLE tmp_release_album
(
    album   INTEGER,
    release INTEGER
);

INSERT INTO tmp_release_album
    SELECT album, id FROM public.release;
INSERT INTO tmp_release_album
    SELECT album, id FROM tmp_new_release;

INSERT INTO release
    (id, gid, release_group, name, artist_credit, status, language, script)
    SELECT
        r.id,
        a.gid::uuid,
        a.release_group,
        n.id,
        a.artist,
        CASE
            WHEN 100 = ANY(a.attributes[2:10]) THEN 1
            WHEN 101 = ANY(a.attributes[2:10]) THEN 2
            WHEN 102 = ANY(a.attributes[2:10]) THEN 3
            WHEN 103 = ANY(a.attributes[2:10]) THEN 4
            ELSE NULL
        END,
        language,
        script
    FROM tmp_new_release r
        JOIN public.album a ON r.album = a.id
        JOIN release_name n ON a.name = n.name;

DROP INDEX tmp_release_name_name_idx;

-- release_meta for releases converted from release events
INSERT INTO release_meta (id, lastupdate, dateadded)
    SELECT r.id, lastupdate, dateadded FROM
        public.release r JOIN public.albummeta am ON r.album=am.id;

-- release_meta for new releases
INSERT INTO release_meta (id, lastupdate, dateadded)
    SELECT r.id, lastupdate, dateadded FROM
        tmp_new_release r JOIN public.albummeta am ON r.album=am.id;

-- convert release events with non-empty label or catno to release_label
INSERT INTO release_label (release, label, catno, position)
    SELECT id, label, catno, 0 FROM public.release
    WHERE label IS NOT NULL OR catno IS NOT NULL OR catno != '';

INSERT INTO tracklist (id, trackcount)
    SELECT a.id, am.tracks
    FROM public.album a JOIN public.albummeta am ON a.id = am.id;

INSERT INTO medium (id, tracklist, release, format, position)
    SELECT r.id, r.album, r.id, NULLIF(r.format, 0), 1
    FROM public.release r;

SELECT SETVAL('medium_id_seq', (SELECT MAX(id) FROM medium));

INSERT INTO medium (tracklist, release, position)
    SELECT album, id, 1 FROM tmp_new_release;

------------------------
-- Release group meta with release counts
------------------------

INSERT INTO release_group_meta
    (id, lastupdate, releasecount, firstreleasedate_year,
     firstreleasedate_month, firstreleasedate_day)
    SELECT m.id, lastupdate, count(*),
        NULLIF(substr(firstreleasedate, 1, 4)::int, 0),
        NULLIF(substr(firstreleasedate, 6, 2)::int, 0),
        NULLIF(substr(firstreleasedate, 9, 2)::int, 0)
    FROM public.release_group_meta m
        LEFT JOIN release r ON r.release_group=m.id
    GROUP BY m.id, m.lastupdate, m.firstreleasedate;

------------------------
-- Artists
------------------------

INSERT INTO artist_name (name)
    (SELECT DISTINCT name FROM public.artist) UNION
    (SELECT DISTINCT sortname FROM public.artist) UNION
    (SELECT DISTINCT name FROM public.artistalias);

CREATE UNIQUE INDEX tmp_artist_name_name ON artist_name (name);

INSERT INTO artist (id, gid, name, sortname, type,
                    begindate_year, begindate_month, begindate_day,
                    enddate_year, enddate_month, enddate_day,
                    comment)
    SELECT
        a.id, gid::uuid, n1.id, n2.id,
        NULLIF(NULLIF(type, 0), 3),
        NULLIF(substr(begindate, 1, 4)::int, 0),
        NULLIF(substr(begindate, 6, 2)::int, 0),
        NULLIF(substr(begindate, 9, 2)::int, 0),
        NULLIF(substr(enddate, 1, 4)::int, 0),
        NULLIF(substr(enddate, 6, 2)::int, 0),
        NULLIF(substr(enddate, 9, 2)::int, 0),
        resolution
    FROM public.artist a JOIN artist_name n1 ON a.name = n1.name JOIN artist_name n2 ON a.sortname = n2.name;

INSERT INTO artist_credit (id, artistcount) SELECT id, 1 FROM artist;

INSERT INTO artist_credit_name (artist_credit, artist, name, position) SELECT id, id, name, 0 FROM artist;

INSERT INTO artist_alias (artist, name)
    SELECT DISTINCT a.ref, n.id
    FROM public.artistalias a JOIN artist_name n ON a.name = n.name;

INSERT INTO artist_meta (id, lastupdate, rating, ratingcount)
    SELECT id, lastupdate, round(rating * 20), rating_count
    FROM public.artist_meta;

DROP INDEX tmp_artist_name_name;

------------------------
-- Labels
------------------------

INSERT INTO label_name (name)
    (SELECT DISTINCT name FROM public.label) UNION
    (SELECT DISTINCT sortname FROM public.label) UNION
    (SELECT DISTINCT name FROM public.labelalias);

CREATE UNIQUE INDEX tmp_label_name_name_idx ON label_name (name);

INSERT INTO label (id, gid, name, sortname, type,
                   begindate_year, begindate_month, begindate_day,
                   enddate_year, enddate_month, enddate_day,
                   comment, country, labelcode)
    SELECT
        a.id, gid::uuid, n1.id, n2.id,
        NULLIF(type, 0),
        NULLIF(substr(begindate, 1, 4)::int, 0),
        NULLIF(substr(begindate, 6, 2)::int, 0),
        NULLIF(substr(begindate, 9, 2)::int, 0),
        NULLIF(substr(enddate, 1, 4)::int, 0),
        NULLIF(substr(enddate, 6, 2)::int, 0),
        NULLIF(substr(enddate, 9, 2)::int, 0),
        resolution, country, labelcode
    FROM public.label a JOIN label_name n1 ON a.name = n1.name JOIN label_name n2 ON a.sortname = n2.name;

INSERT INTO label_alias (label, name)
    SELECT DISTINCT a.ref, n.id
    FROM public.labelalias a JOIN label_name n ON a.name = n.name;

INSERT INTO label_meta (id, lastupdate, rating, ratingcount)
    SELECT id, lastupdate, round(rating * 20), rating_count
    FROM public.label_meta;

DROP INDEX tmp_label_name_name_idx;

------------------------
-- Tracks
------------------------

INSERT INTO track_name (name)
    SELECT DISTINCT name FROM public.track;

CREATE UNIQUE INDEX tmp_track_name_name ON track_name (name);

INSERT INTO recording (id, gid, name, artist_credit, length)
    SELECT a.id, gid::uuid, n.id, a.artist, a.length
    FROM public.track a
        JOIN track_name n ON n.name = a.name;

INSERT INTO track (id, tracklist, name, recording, artist_credit, length, position)
    SELECT t.id, a.album, n.id, t.id, t.artist, length, a.sequence
    FROM public.track t
        JOIN public.albumjoin a ON t.id = a.track
        JOIN track_name n ON n.name = t.name;

INSERT INTO recording_meta (id, rating, ratingcount)
    SELECT id, round(rating * 20), rating_count
    FROM public.track_meta;

DROP INDEX tmp_track_name_name;

------------------------
-- Redirects
------------------------

INSERT INTO artist_gid_redirect SELECT gid::uuid, newid FROM public.gid_redirect WHERE tbl=2;
INSERT INTO label_gid_redirect SELECT gid::uuid, newid FROM public.gid_redirect WHERE tbl=4;
INSERT INTO recording_gid_redirect SELECT gid::uuid, newid FROM public.gid_redirect WHERE tbl=3;
-- Redirects for releases converted from albums
INSERT INTO release_gid_redirect
    SELECT gid_redirect.gid::uuid, tmp_release_gid.id
    FROM public.gid_redirect
        JOIN tmp_release_gid ON gid_redirect.newid=tmp_release_gid.album
    WHERE tbl=1;
-- Redirects for newly created releases
INSERT INTO release_gid_redirect
    SELECT gid_redirect.gid::uuid, tmp_new_release.id
    FROM public.gid_redirect
        JOIN tmp_new_release ON gid_redirect.newid=tmp_new_release.album
    WHERE tbl=1;
INSERT INTO release_group_gid_redirect SELECT gid::uuid, newid FROM public.gid_redirect WHERE tbl=5;

------------------------
-- Editors
------------------------

INSERT INTO editor (id, name, password, privs, email, website, bio,
    membersince, emailconfirmdate, lastlogindate, editsaccepted,
    editsrejected, autoeditsaccepted, editsfailed)
    SELECT id, name, password, privs, email, weburl, bio, membersince,
        emailconfirmdate, lastlogindate, modsaccepted, modsrejected,
        automodsaccepted, modsfailed FROM public.moderator;

INSERT INTO editor_preference (id, editor, name, value)
    SELECT
        id, moderator,
        CASE
            WHEN name = 'subscriptions_public' THEN 'public_subscriptions'
            WHEN name = 'tags_public' THEN 'public_tags'
            WHEN name = 'ratings_public' THEN 'public_ratings'
            WHEN name = 'datetimeformat' THEN 'datetime_format'
            ELSE name
        END, value
        FROM public.moderator_preference;
INSERT INTO editor_subscribe_artist SELECT * FROM public.moderator_subscribe_artist;
INSERT INTO editor_subscribe_label SELECT * FROM public.moderator_subscribe_label;
INSERT INTO editor_subscribe_editor SELECT * FROM public.editor_subscribe_editor;

------------------------
-- Annotations
------------------------

INSERT INTO annotation (id, editor, text, changelog, created)
    SELECT a.id, moderator, text, changelog, created
    FROM public.annotation a, public.moderator
    WHERE a.moderator=moderator.id AND type IN (1, 3, 4);

INSERT INTO artist_annotation
    SELECT rowid, a.id FROM public.annotation a, public.moderator
    WHERE a.moderator=moderator.id AND type = 1;

INSERT INTO label_annotation
    SELECT rowid, a.id FROM public.annotation a, public.moderator
    WHERE a.moderator=moderator.id AND type = 3;

INSERT INTO recording_annotation
    SELECT rowid, a.id FROM public.annotation a, public.moderator, public.track as t
    WHERE a.moderator=moderator.id AND type = 4 AND a.rowid = t.id;

CREATE OR REPLACE FUNCTION tmp_join_append(VARCHAR, VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    state ALIAS FOR $1;
    value ALIAS FOR $2;
BEGIN
    IF (value IS NULL) THEN RETURN state; END IF;
    IF (state IS NULL) THEN
        RETURN value;
    ELSE
        RETURN(state || E'\n----\n' || value);
    END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE AGGREGATE tmp_join(BASETYPE = VARCHAR, SFUNC=tmp_join_append, STYPE=VARCHAR);

SELECT SETVAL('annotation_id_seq', (SELECT MAX(id) FROM annotation));

SELECT nextval('annotation_id_seq') AS id, release_group,
    MIN(moderator) AS editor, MIN(text) AS text,
    MIN(changelog) AS changelog, MIN(created) AS created
INTO TEMPORARY tmp_release_group_annotation
FROM
    public.annotation a
    JOIN public.moderator ON a.moderator=moderator.id
    JOIN public.album ON a.rowid=album.id
WHERE type = 2
GROUP BY release_group
HAVING COUNT(*) = 1;

INSERT INTO tmp_release_group_annotation
    SELECT nextval('annotation_id_seq') AS id, release_group,
        4 AS editor, tmp_join(text) AS text, 'Merge', NOW() AS created
    FROM
        public.annotation a
        JOIN public.moderator ON a.moderator=moderator.id
        JOIN public.album ON a.rowid=album.id
    WHERE type = 2
    GROUP BY release_group
    HAVING COUNT(*) != 1;

DROP AGGREGATE tmp_join(VARCHAR);
DROP FUNCTION tmp_join_append(VARCHAR, VARCHAR);

INSERT INTO annotation (id, editor, text, changelog, created)
    SELECT id, editor, text, changelog, created
    FROM tmp_release_group_annotation;

INSERT INTO release_group_annotation
    SELECT release_group, id
    FROM tmp_release_group_annotation;

------------------------
-- PUIDs
------------------------

INSERT INTO clientversion SELECT * FROM public.clientversion;

INSERT INTO puid (id, puid, version)
    SELECT id, puid, version FROM public.puid;

INSERT INTO recording_puid (id, puid, recording)
    SELECT id, puid, track FROM public.puidjoin;

------------------------
-- ISRCs
------------------------

INSERT INTO isrc (id, recording, isrc, source, editpending)
    SELECT id, track, isrc, source, modpending FROM public.isrc;

------------------------
-- DiscIDs
------------------------

INSERT INTO cdtoc SELECT * FROM public.cdtoc;

INSERT INTO tracklist_cdtoc (id, tracklist, cdtoc, editpending)
    SELECT id, album, cdtoc, modpending FROM public.album_cdtoc;

COMMIT;
