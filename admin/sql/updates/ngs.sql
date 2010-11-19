BEGIN;

------------------------
-- Misc
------------------------

INSERT INTO country
    SELECT id, isocode AS iso_code, name
    FROM public.country WHERE id!=239; -- Exclude [Unknown Country]

INSERT INTO language
    SELECT id, isocode_3t AS iso_code_3t, isocode_3b AS iso_code_3b,
           isocode_2 AS iso_code_2, name, frequency
    FROM public.language;

INSERT INTO script
    SELECT id, isocode AS iso_code, isonumber AS iso_number,
           name, frequency
    FROM public.script;

INSERT INTO script_language SELECT * FROM public.script_language;

INSERT INTO gender (id, name) VALUES
    (1, 'Male'),
    (2, 'Female'),
    (3, 'Other');

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
    (15, 'Piano Roll', 1883),
    (16, 'DCC', 1992),
    (17, 'HD-DVD', NULL),
    (20, 'Blu-ray', NULL),
    (21, 'VHS', NULL),
    (22, 'VCD', NULL),
    (23, 'SVCD', NULL),
    (24, 'Betamax', NULL),
    (25, 'HDCD', NULL),
    (26, 'USB Flash Drive', NULL),
    (27, 'slotMusic', NULL),
    (28, 'UMD', NULL);
INSERT INTO medium_format (id, name, year, child_order, parent) VALUES
    (29, '7"', NULL, 0, 7),
    (30, '10"', NULL, 1, 7),
    (31, '12"', NULL, 2, 7),
    (18, 'DVD-Audio', NULL, 0, 2),
    (19, 'DVD-Video', NULL, 1, 2);

INSERT INTO url
    SELECT id, gid::uuid, url, description, refcount AS ref_count
    FROM public.url;

INSERT INTO replication_control SELECT * FROM public.replication_control;
INSERT INTO currentstat
    SELECT id, name, value, lastupdated AS last_updated
    FROM public.currentstat;
INSERT INTO historicalstat SELECT * FROM public.historicalstat;

------------------------
-- Tags
------------------------

INSERT INTO tag
    SELECT id, name, refcount AS ref_count
    FROM public.tag;

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

INSERT INTO release_group (id, gid, name, type, artist_credit, last_updated)
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
        END, COALESCE(new_ac, artist), r.lastupdate as last_updated
    FROM public.release_group a
        JOIN release_name n ON a.name = n.name
        JOIN public.albummeta r ON a.id = r.id
        LEFT JOIN tmp_artist_credit_repl acr ON artist=old_ac;

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
     date_year, date_month, date_day, country, language, script,
     quality, last_updated)
    SELECT
        r.id,
        CASE WHEN g.gid IS NULL THEN
            generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/release/?id=' || r.id)
        ELSE g.gid END,
        a.release_group,
        n.id,
        COALESCE(new_ac, a.artist),
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
        NULLIF(country, 239), -- Use NULL instead of [Unknown Country]
        language,
        script,
        quality,
        m.lastupdate AS last_updated
    FROM public.release r
        JOIN public.album a ON r.album = a.id
        JOIN release_name n ON a.name = n.name
        JOIN public.albummeta m ON a.id = m.id
        LEFT JOIN tmp_release_gid g ON r.id=g.id
        LEFT JOIN tmp_artist_credit_repl acr ON a.artist=old_ac;

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
    (id, gid, release_group, name, artist_credit, status, language, script,
    quality, last_updated)
    SELECT
        r.id,
        a.gid::uuid,
        a.release_group,
        n.id,
        COALESCE(new_ac, a.artist),
        CASE
            WHEN 100 = ANY(a.attributes[2:10]) THEN 1
            WHEN 101 = ANY(a.attributes[2:10]) THEN 2
            WHEN 102 = ANY(a.attributes[2:10]) THEN 3
            WHEN 103 = ANY(a.attributes[2:10]) THEN 4
            ELSE NULL
        END,
        language,
        script,
        quality,
        m.lastupdate
    FROM tmp_new_release r
        JOIN public.album a ON r.album = a.id
        JOIN release_name n ON a.name = n.name
        JOIN public.albummeta m ON a.id = m.id
        LEFT JOIN tmp_artist_credit_repl acr ON a.artist=old_ac;

DROP INDEX tmp_release_name_name_idx;

-- release_meta for releases converted from release events
INSERT INTO release_meta
    SELECT r.id, dateadded FROM
        public.release r JOIN public.albummeta am ON r.album=am.id;

-- release_meta for new releases
INSERT INTO release_meta (id, date_added)
    SELECT r.id, dateadded FROM
        tmp_new_release r JOIN public.albummeta am ON r.album=am.id;

-- convert release events with non-empty label or catalog_number to release_label
INSERT INTO release_label (release, label, catalog_number)
    SELECT id, label, catno FROM public.release
    WHERE label IS NOT NULL OR catno IS NOT NULL OR catno != '';

INSERT INTO tracklist (id, track_count)
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
    (id, release_count, first_release_date_year,
     first_release_date_month, first_release_date_day)
    SELECT m.id, count(*),
        NULLIF(substr(firstreleasedate, 1, 4)::int, 0),
        NULLIF(substr(firstreleasedate, 6, 2)::int, 0),
        NULLIF(substr(firstreleasedate, 9, 2)::int, 0)
    FROM public.release_group_meta m
        LEFT JOIN release r ON r.release_group=m.id
    GROUP BY m.id, m.lastupdate, m.firstreleasedate;

------------------------
-- Labels
------------------------

INSERT INTO label_name (name)
    (SELECT DISTINCT name FROM public.label) UNION
    (SELECT DISTINCT sortname FROM public.label) UNION
    (SELECT DISTINCT name FROM public.labelalias);

CREATE UNIQUE INDEX tmp_label_name_name_idx ON label_name (name);

INSERT INTO label (id, gid, name, sort_name, type,
                   begin_date_year, begin_date_month, begin_date_day,
                   end_date_year, end_date_month, end_date_day,
                   comment, country, label_code, last_updated)
    SELECT
        a.id, gid::uuid, n1.id, n2.id,
        NULLIF(type, 0),
        NULLIF(substr(begindate, 1, 4)::int, 0),
        NULLIF(substr(begindate, 6, 2)::int, 0),
        NULLIF(substr(begindate, 9, 2)::int, 0),
        NULLIF(substr(enddate, 1, 4)::int, 0),
        NULLIF(substr(enddate, 6, 2)::int, 0),
        NULLIF(substr(enddate, 9, 2)::int, 0),
        resolution,
        NULLIF(country, 239), -- Use NULL instead of [Unknown Country]
        labelcode,
        m.lastupdate AS last_updated
    FROM public.label a 
    JOIN label_name n1 ON a.name = n1.name 
    JOIN label_name n2 ON a.sortname = n2.name
    JOIN public.label_meta m ON a.id = m.id;

INSERT INTO label_alias (label, name)
    SELECT DISTINCT a.ref, n.id
    FROM public.labelalias a JOIN label_name n ON a.name = n.name;

INSERT INTO label_meta (id, rating, rating_count)
    SELECT id, round(rating * 20), rating_count
    FROM public.label_meta;

DROP INDEX tmp_label_name_name_idx;

------------------------
-- Tracks
------------------------

INSERT INTO track_name (name)
    SELECT DISTINCT name FROM public.track;

CREATE UNIQUE INDEX tmp_track_name_name ON track_name (name);

INSERT INTO recording (id, gid, name, artist_credit, length, last_updated)
    SELECT a.id, gid::uuid, n.id, COALESCE(new_ac, a.artist), a.length, NULL
    FROM public.track a
        JOIN track_name n ON n.name = a.name
        LEFT JOIN tmp_artist_credit_repl acr ON a.artist=old_ac;

INSERT INTO track (id, tracklist, name, recording, artist_credit, length, position, last_updated)
    SELECT t.id, a.album, n.id, t.id, COALESCE(new_ac, t.artist), length, a.sequence, NULL
    FROM public.track t
        JOIN public.albumjoin a ON t.id = a.track
        JOIN track_name n ON n.name = t.name
        LEFT JOIN tmp_artist_credit_repl acr ON t.artist=old_ac;

INSERT INTO recording_meta (id, rating, rating_count)
    SELECT id, round(rating * 20), rating_count
    FROM public.track_meta;

DROP INDEX tmp_track_name_name;

------------------------
-- Works
------------------------

CREATE OR REPLACE FUNCTION clean_work_name(name TEXT) RETURNS TEXT AS $$
BEGIN
    RETURN btrim(
        regexp_replace(
            regexp_replace(name, E'\\(feat. .*?\\)', ''),
                E'\\(live(,.*?| at.*?)\\)', '')
    );
END;
$$ LANGUAGE 'plpgsql';

SELECT id INTO TEMPORARY tmp_work 
FROM ( 
        SELECT link1 AS id
            FROM public.l_artist_track l
                JOIN public.lt_artist_track lt ON lt.id = l.link_type
            WHERE lt.name IN ('composition', 'composer', 'arranger', 'lyricist', 'instrumentator',
                             'orchestrator', 'librettist', 'misc')
        UNION
        SELECT link1 AS id
            FROM public.l_label_track l
                JOIN public.lt_label_track lt ON lt.id = l.link_type
            WHERE lt.name IN ('publishing')
        UNION
        SELECT link0 AS id
            FROM public.l_track_track l
                JOIN public.lt_track_track lt ON lt.id = l.link_type
            WHERE lt.name IN ('other version', 'medley', 'remaster', 'karaoke')
        UNION
        SELECT link1 AS id
            FROM public.l_track_track l
                JOIN public.lt_track_track lt ON lt.id = l.link_type
            WHERE lt.name IN ('other version', 'medley', 'remaster', 'karaoke')
        UNION
        SELECT link0 AS id
            FROM public.l_track_url l
                JOIN public.lt_track_url lt ON lt.id = l.link_type
            WHERE lt.name IN ('lyrics', 'score', 'ibdb', 'iobdb', 'publishing', 'misc')
) t;
CREATE UNIQUE INDEX tmp_work_id ON tmp_work (id);

INSERT INTO work_name (name)
    SELECT DISTINCT regexp_replace(track.name, E' \\(feat. .*?\\)', '')
    FROM public.track
        JOIN tmp_work t ON track.id = t.id;

CREATE UNIQUE INDEX tmp_work_name_name ON work_name (name);

INSERT INTO work (id, gid, name, artist_credit, last_updated)
    SELECT DISTINCT track.id, generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://musicbrainz.org/work/?id=' || track.id), 
        n.id, COALESCE(new_ac, track.artist), NULL::timestamp with time zone
    FROM public.track 
        JOIN tmp_work t ON track.id = t.id  
        JOIN work_name n ON n.name = regexp_replace(track.name, E' \\(feat. .*?\\)', '')
        LEFT JOIN tmp_artist_credit_repl acr ON track.artist=old_ac;

DROP INDEX tmp_work_name_name;
DROP INDEX tmp_work_id;
DROP FUNCTION clean_work_name (TEXT);

------------------------
-- Redirects
------------------------

INSERT INTO artist_gid_redirect SELECT gid::uuid, newid AS new_id FROM public.gid_redirect WHERE tbl=2;
INSERT INTO label_gid_redirect SELECT gid::uuid, newid AS new_id FROM public.gid_redirect WHERE tbl=4;
INSERT INTO recording_gid_redirect SELECT gid::uuid, newid AS new_id FROM public.gid_redirect WHERE tbl=3;
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
INSERT INTO release_group_gid_redirect SELECT gid::uuid, newid AS new_id FROM public.gid_redirect WHERE tbl=5;

------------------------
-- Editors
------------------------

INSERT INTO editor (id, name, password, privs, email, website, bio,
    email_confirm_date, last_login_date, edits_accepted,
    edits_rejected, auto_edits_accepted, edits_failed, member_since)
    SELECT id, name, password, privs, email, weburl, bio,
        emailconfirmdate, lastlogindate, modsaccepted, modsrejected,
        automodsaccepted, modsfailed,
        CASE
            WHEN membersince < '2000-01-01' THEN NULL
            ELSE membersince
        END
        FROM public.moderator;

INSERT INTO editor_preference (id, editor, name, value)
    SELECT
        id, moderator,
        CASE
            WHEN name = 'subscriptions_public' THEN 'public_subscriptions'
            WHEN name = 'tags_public' THEN 'public_tags'
            WHEN name = 'ratings_public' THEN 'public_ratings'
            WHEN name = 'datetimeformat' THEN 'datetime_format'
            ELSE name
        END AS name,
        CASE
            WHEN name = 'timezone' AND value = 'HAST10HADT'     THEN 'America/Adak'
            WHEN name = 'timezone' AND value = 'AST4ADT'        THEN 'America/Thule'
            WHEN name = 'timezone' AND value = 'NST03:30NDT'    THEN 'America/St_Johns'
            WHEN name = 'timezone' AND value = 'GST3GDT'        THEN 'GMT'
            WHEN name = 'timezone' AND value = 'AZOT2AZOST'     THEN 'Atlantic/Azores'
            WHEN name = 'timezone' AND value = 'WAT0WEST'       THEN 'WET'
            WHEN name = 'timezone' AND value = 'WAT1WAST'       THEN 'Africa/Windhoek'
            WHEN name = 'timezone' AND value = 'GMT0BST'        THEN 'Europe/London'
            WHEN name = 'timezone' AND value = 'CET-1CEST'      THEN 'CET'
            WHEN name = 'timezone' AND value = 'EET-2EEST'      THEN 'EET'
            WHEN name = 'timezone' AND value = 'IST-05:30IDT'   THEN 'Asia/Calcutta'
            WHEN name = 'timezone' AND value = 'AWST-8AWDT'     THEN 'Australia/Perth'
            WHEN name = 'timezone' AND value = 'KST-9KDT'       THEN 'Asia/Seoul'
            WHEN name = 'timezone' AND value = 'JST-9JDT'       THEN 'Asia/Tokyo'
            WHEN name = 'timezone' AND value = 'ACST-09:30ACDT' THEN 'Australia/Adelaide'
            WHEN name = 'timezone' AND value = 'AEST-10AEDT'    THEN 'Australia/Melbourne'
            WHEN name = 'timezone' AND value = 'IDLE-12'        THEN 'Pacific/Auckland'
            WHEN name = 'timezone' AND value = 'NZST-12NZDT'    THEN 'Pacific/Auckland'
            WHEN name = 'timezone' AND value = 'WET0WEST'       THEN 'WET'
            WHEN name = 'timezone' AND value LIKE 'Etc/GMT%'    THEN 'Etc/GMT'
            WHEN name = 'timezone' AND value LIKE 'posix/%'     THEN substr(value, 7)
            ELSE value
        END AS value
        FROM public.moderator_preference
        WHERE name NOT IN (
            'mod_add_album_link', 'navbar_mod_show_select_page', 'vote_abs_default',
            'remove_recent_link_on_add', 'reveal_address_when_mailing',
            'sendcopy_when_mailing', 'JSDiff', 'show_ratings', 'release_show_relationshipslinks',
            'release_show_annotationlinks', 'use_amazon_store', 'google_domain',
            'topmenu_submenu_types', 'topmenu_dropdown_trigger', 'JSMoveFocus',
            'JSDebug', 'sidebar_panel_sites', 'sidebar_panel_user', 'sidebar_panel_search',
            'sidebar_panel_topmods', 'sidebar_panel_stats', 'nosidebar', 'css_noentityicons',
            'show_inline_mods', 'show_inline_mods_random', 'css_nosmallfonts',
            'autofix_open'
        );

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

SELECT SETVAL('annotation_id_seq', (SELECT MAX(id) FROM annotation));

SELECT nextval('annotation_id_seq') AS id, r.release,
    moderator AS editor, text, changelog, created
INTO TEMPORARY tmp_release_annotation
FROM
    public.annotation a, tmp_release_album r, public.moderator
WHERE a.moderator = moderator.id AND a.type = 2 AND a.rowid = r.album;

INSERT INTO annotation (id, editor, text, changelog, created)
    SELECT id, editor, text, changelog, created
    FROM tmp_release_annotation;

INSERT INTO release_annotation
    SELECT release, id
    FROM tmp_release_annotation;

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

INSERT INTO isrc (id, recording, isrc, source, edits_pending)
    SELECT id, track, isrc, source, modpending FROM public.isrc;

------------------------
-- DiscIDs
------------------------

INSERT INTO cdtoc SELECT * FROM public.cdtoc;

INSERT INTO medium_cdtoc (medium, cdtoc)
    SELECT m.id, ac.cdtoc
    FROM tmp_release_album re
        JOIN public.album_cdtoc ac ON re.album=ac.album
        JOIN medium m ON m.release=re.release
    WHERE m.format IS NULL OR m.format IN (1,4); -- Unknown, CD or DualDisc

COMMIT;
