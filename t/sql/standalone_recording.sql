INSERT INTO artist (id, gid, name, sort_name, begin_date_year, begin_date_month, begin_date_day, end_date_year, end_date_month, end_date_day, type, area, gender, comment, edits_pending, last_updated, ended, begin_area, end_area)
    VALUES (42649, '841db5c8-7072-4b89-9bdb-0a0bd0e9d357', 'Yiruma', 'Yiruma', 1978, 2, 15, NULL, NULL, NULL, 1, 113, 1, '', 0, '2016-11-05 13:01:05.921803+00', 'f', NULL, NULL);

INSERT INTO artist_credit (id, name, artist_count, ref_count, created, edits_pending, gid)
    VALUES (42649, 'Yiruma', 1, 1111, '2011-05-16 16:32:11.963929+00', 0, 'e8428733-abf6-3529-9849-fe081b944ca2');

INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (42649, 0, 42649, 'Yiruma', '');

INSERT INTO recording (id, gid, name, artist_credit, length, comment, edits_pending, last_updated, video)
    VALUES (11959204, 'c289a368-867e-4ae0-a1ac-ba28a99822f3', '[silence]', 42649, 10000, '', 0, '2012-04-23 23:00:09.754657+00', 'f');
