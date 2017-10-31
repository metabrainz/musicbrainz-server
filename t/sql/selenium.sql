\set ON_ERROR_STOP 1

BEGIN;

-- Skip past $EDITOR_MODBOT.
SELECT setval('editor_id_seq', 5, FALSE);

-- Skip past special purpose artists.
SELECT setval('artist_id_seq', 3, FALSE);

INSERT INTO artist (area, begin_area, begin_date_day, begin_date_month, begin_date_year, comment, edits_pending, end_area, end_date_day, end_date_month, end_date_year, ended, gender, gid, id, last_updated, name, sort_name, type) VALUES
    (NULL, NULL, 8, 1, 1947, '', 0, NULL, 10, 1, 2016, '1', 1, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 956, '2016-02-07 10:16:37.066958+00', 'David Bowie', 'Bowie, David', 1),
    (NULL, NULL, 3, 5, 1903, '', 0, NULL, 14, 10, 1977, '1', 1, '2437980f-513a-44fc-80f1-b90d9d7fcf8f', 99, '2016-11-07 12:01:02.968948+00', 'Bing Crosby', 'Crosby, Bing', 1);

INSERT INTO artist_credit (id, name, artist_count, ref_count) VALUES
    (956, 'David Bowie', 1, 2);

INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase) VALUES
    (956, 0, 956, 'David Bowie', '');

INSERT INTO link_type (id, parent, child_order, gid, entity_type0, entity_type1, name, description, link_phrase, reverse_link_phrase, long_link_phrase, priority, last_updated, is_deprecated, has_dates, entity0_cardinality, entity1_cardinality) VALUES
    (666, 188, 0, 'baf4b924-088c-41b3-8b49-7a4d1d5f3be9', 'artist', 'url', 'musicmoz', '', 'MusicMoz', 'MusicMoz page for', 'has a MusicMoz page at', 0, '2017-09-11 04:00:09.052103+00', true, false, 0, 0);

INSERT INTO release_group (id, gid, name, artist_credit, type, comment) VALUES
    (1581583, '1fd18f5b-9a92-41fd-a590-da6b5cc60d85', '★', 956, 1, 'Blackstar');

INSERT INTO release (id, gid, name, artist_credit, release_group, status, packaging, language, script, barcode, comment, quality) VALUES
    (1693299, '24d4159a-99d9-425d-a7b8-1b9ec0261a33', '★', 956, 1581583, 1, 3, 120, 28, '888751738621', '', -1);

COMMIT;
