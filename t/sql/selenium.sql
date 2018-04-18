\set ON_ERROR_STOP 1

BEGIN;

-- Skip past $EDITOR_MODBOT.
SELECT setval('editor_id_seq', 5, FALSE);

-- Skip past special purpose artists.
SELECT setval('artist_id_seq', 3, FALSE);

INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
    (NULL, NULL, 8, 1, 1947, '', 0, NULL, 10, 1, 2016, '1', 1, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 956, '2016-02-07 10:16:37.066958+00', 'David Bowie', 'Bowie, David', 1),
    (NULL, NULL, 3, 5, 1903, '', 0, NULL, 14, 10, 1977, '1', 1, '2437980f-513a-44fc-80f1-b90d9d7fcf8f', 99, '2016-11-07 12:01:02.968948+00', 'Bing Crosby', 'Crosby, Bing', 1),
    (NULL, NULL, NULL, NULL, NULL, '', 0, NULL, NULL, NULL,  NULL, '0', NULL, '4f74991f-0156-427a-88db-9b2ac293dd42', 1647244, '2018-04-11 10:07:10.225834+00', 'The David Bowie Knives', 'David Bowie Knives, The', 2);

INSERT INTO artist_credit (id, name, artist_count, ref_count) VALUES
    (956, 'David Bowie', 1, 2),
    (2196047, 'The David Bowie Knives', 1, 2);

INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
    (956, 0, 956, 'David Bowie', ''),
    (2196047, 0, 1647244, 'The David Bowie Knives', '');

INSERT INTO link_type (id, parent, child_order, gid, entity_type0, entity_type1, name, description, link_phrase, reverse_link_phrase, long_link_phrase, priority, last_updated, is_deprecated, has_dates, entity0_cardinality, entity1_cardinality) VALUES
--    (74, 73, 1, '98e08c20-8402-4163-8970-53504bb6a1e4', 'release', 'url', 'purchase for download', 'This is used to link to a page where the release can be purchased for download.', 'purchase for download', 'download purchase page for', 'can be purchased for download at', 0, '2013-12-10 13:51:19.794106+00', false, true, 0, 0),
--    (85, 73, 3, '08445ccf-7b99-4438-9f9a-fb9ac18099ee', 'release', 'url', 'streaming music', 'This relationship type is used to link a release to a site where the tracks can be legally streamed for free, e.g. Spotify.', 'stream {video} for free', 'free music {video} streaming page for', '{video} can be streamed for free at', 0, '2014-01-19 02:56:04.116246+00', false, true, 0, 0),
    (666, 188, 0, 'baf4b924-088c-41b3-8b49-7a4d1d5f3be9', 'artist', 'url', 'musicmoz', '', 'MusicMoz', 'MusicMoz page for', 'has a MusicMoz page at', 0, '2017-09-11 04:00:09.052103+00', true, false, 0, 0);

INSERT INTO link (id, link_type, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, attribute_count, created, ended) VALUES
    (6313, 74, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2011-05-16 15:03:23.368437+00', false),
    (6330, 85, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2011-05-16 15:03:23.368437+00', false);

INSERT INTO release_group (id, gid, name, artist_credit, type, comment) VALUES
    (1581583, '1fd18f5b-9a92-41fd-a590-da6b5cc60d85', '★', 956, 1, 'Blackstar'),
    (1954919, '566b08ae-2b02-4fdb-a5d8-6a54fd16df27', 'Weapons of Mass Seduction', 2196047, 1, '');

INSERT INTO release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode, comment, quality) VALUES
    (1693299, '24d4159a-99d9-425d-a7b8-1b9ec0261a33', '★', 956, 1581583, 1, 3, 120, 28, '888751738621', '', -1),
    (2154808, '1bda2f85-0576-4077-b3fa-0fc939079b61', 'Weapons of Mass Seduction', 2196047, 1954919, 1, NULL, 120, 28, NULL, '', -1);

INSERT INTO url (id, gid, url, edits_pending, last_updated) VALUES
    (4948549, '86d65e08-8331-4614-a387-816abdba0045', 'http://thedavidbowieknives.bandcamp.com/album/weapons-of-mass-seduction', 0, '2018-04-11 10:09:59.527876+00');

INSERT INTO l_release_url (id, link, entity0, entity1, edits_pending, last_updated, link_order, entity0_credit, entity1_credit) VALUES
    (2036110, 6313, 2154808, 4948549, 0, '2018-04-11 10:09:59.527876+00', 0, '', ''),
    (2036111, 6330, 2154808, 4948549, 0, '2018-04-11 10:09:59.527876+00', 0, '', '');

COMMIT;
